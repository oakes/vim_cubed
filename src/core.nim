import nimgl/opengl
import paranim/gl, paranim/gl/uniforms, paranim/gl/attributes
import paranim/math as pmath
import common, data
from bitops import bitor
from std/math import nil
import glm
from paravim/core as paravim import nil

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
  position.data[].add(posData)
  # texcoord
  var texcoord = Attribute[GLfloat](size: 2, iter: 1, normalize: true)
  new(texcoord.data)
  texcoord.data[].add(texcoordData)
  # set attrs and unis
  result.attributes = (a_position: position, a_texcoord: texcoord)
  result.uniforms = (
    u_matrix: Uniform[Mat4x4[GLfloat]](data: mat4f(1)),
    u_texture: Uniform[RenderToTexture[GLubyte, Game]](data: image)
  )

var entity: ThreeDMetaTextureEntity
var rx = degToRad(180f)
var ry = degToRad(40f)
const targetWidth = 512
const targetHeight = 512

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_DEPTH_TEST)

  paravim.onWindowResize(targetWidth, targetHeight)

  paravim.insert(paravim.session, paravim.Global, paravim.AsciiArt, "")

  let outerImage = RenderToTexture[GLubyte, Game](
    opts: TextureOpts(
      mipLevel: 0,
      internalFmt: GL_RGBA,
      width: GLsizei(targetWidth),
      height: GLsizei(targetHeight),
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
      paravim.tick(game, true)
  )

  entity = compile(game, initThreeDMetaTextureEntity(cube, cubeTexcoords, outerImage))

proc tick*(game: Game) =
  glEnable(GL_CULL_FACE)

  glClearColor(1f, 1f, 1f, 1f)
  glClear(GLbitfield(bitor(GL_COLOR_BUFFER_BIT.ord, GL_DEPTH_BUFFER_BIT.ord)))
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

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

