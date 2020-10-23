import nimgl/opengl
import paranim/gl, paranim/gl/uniforms, paranim/gl/attributes, paranim/gl/entities
import paranim/math as pmath
import common, data
from bitops import bitor
from std/math import nil
import glm
from paravim/core as paravim_core import nil
from paravim import nil
import stb_image/read as stbi
from pararules import nil

type
  ThreeDMetaTextureEntityUniforms = tuple[u_matrix: Uniform[Mat4x4[GLfloat]], u_texture: Uniform[RenderToTexture[GLubyte, Game]]]
  ThreeDMetaTextureEntityAttributes = tuple[a_position: Attribute[GLfloat], a_texcoord: Attribute[GLfloat]]
  ThreeDMetaTextureEntity = object of ArrayEntity[ThreeDMetaTextureEntityUniforms, ThreeDMetaTextureEntityAttributes]
  UncompiledThreeDMetaTextureEntity = object of UncompiledEntity[ThreeDMetaTextureEntity, ThreeDMetaTextureEntityUniforms, ThreeDMetaTextureEntityAttributes]

proc initThreeDMetaTextureEntity(posData: openArray[GLfloat], texcoordData: openArray[GLfloat], image: RenderToTexture[GLubyte, Game]): UncompiledThreeDMetaTextureEntity =
  result.vertexSource = threeDTextureVertexShader
  result.fragmentSource = threeDTextureFragmentShader
  # position
  var position = Attribute[GLfloat](size: 3, iter: 1)
  new(position.data)
  position.data[] = @posData
  # texcoord
  var texcoord = Attribute[GLfloat](size: 2, iter: 1, normalize: true)
  new(texcoord.data)
  texcoord.data[] = @texcoordData
  # set attrs and unis
  result.attributes = (a_position: position, a_texcoord: texcoord)
  result.uniforms = (
    u_matrix: Uniform[Mat4x4[GLfloat]](data: mat4f(1)),
    u_texture: Uniform[RenderToTexture[GLubyte, Game]](data: image)
  )

var
  entity: ThreeDMetaTextureEntity
  imageEntity: ImageEntity
  hammerEntity: ImageEntity
  rx = degToRad(180f)
  ry = degToRad(40f)
  imageWidth: int
  imageHeight: int

const image = staticRead("assets/bg.jpg")
const hammerTime = staticRead("assets/hammertime.jpg")


proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_DEPTH_TEST)

  let
    windowWidth = pararules.query(paravim_core.session, paravim_core.rules.getWindow).windowWidth
    cubeSize = int(windowWidth / 2)
  paravim_core.onWindowResize(cubeSize, cubeSize)
  paravim_core.insert(paravim_core.session, paravim_core.Global, paravim_core.AsciiArt, "")

  let outerImage = RenderToTexture[GLubyte, Game](
    opts: TextureOpts(
      mipLevel: 0,
      internalFmt: GL_RGBA,
      width: GLsizei(cubeSize),
      height: GLsizei(cubeSize),
      border: 0,
      srcFmt: GL_RGBA
    ),
    params: @[
      (GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE),
      (GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE),
      (GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    ],
    render: proc (game: Game) =
      glDisable(GL_CULL_FACE)
      discard paravim.tick(game, true)
      glEnable(GL_CULL_FACE)
  )

  entity = compile(game, initThreeDMetaTextureEntity(cube, cubeTexcoords, outerImage))

  var
    channels: int
    data: seq[uint8]
    hammerData: seq[uint8]
  data = stbi.loadFromMemory(cast[seq[uint8]](image), imageWidth, imageHeight, channels, stbi.RGBA)
  imageEntity = compile(game, initImageEntity(data, imageWidth, imageHeight))
  hammerData = stbi.loadFromMemory(cast[seq[uint8]](hammerTime), imageWidth, imageHeight, channels, stbi.RGBA)
  hammerEntity = compile(game, initImageEntity(hammerData, imageWidth, imageHeight))

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GLbitfield(bitor(GL_COLOR_BUFFER_BIT.ord, GL_DEPTH_BUFFER_BIT.ord)))
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  block:
    glDisable(GL_CULL_FACE)
    let
      frameRatio = game.frameWidth.float / game.frameHeight.float
      imageRatio = imageWidth.float / imageHeight.float
      (width, height) =
        if frameRatio > imageRatio:
          (game.frameWidth.float, game.frameWidth.float * (imageHeight.float / imageWidth.float))
        else:
          (game.frameHeight.float * imageRatio, game.frameHeight.float)
    var e = imageEntity
    if game.isHammerTime == true:
      e = hammerEntity
    else:
      e = imageEntity
    e.project(float(game.frameWidth), float(game.frameHeight))
    e.translate(0f, 0f)
    e.scale(width, height)
    render(game, e)

  var camera = mat4f(1)
  camera.translate(0f, 0f, 2f)
  camera.lookAt(vec3(0f, 0f, 0f), vec3(0f, 1f, 0f))

  var e = entity
  e.project(degToRad(60f), float(game.frameWidth) / float(game.frameHeight), 1f, 2000f)
  e.invert(camera)
  e.rotateX(rx)
  e.rotateY(ry)
  e.scale(1.15f, 1.15f, 1.15f)
  render(game, e)

  rx += 0.5f * game.deltaTime
  ry += 0.5f * game.deltaTime

