import paranim/gl, paranim/gl/uniforms
import nimgl/opengl
import glm
from std/math import nil
import paranim/math as pmath

type
  Game* = object of RootGame
    deltaTime*: float
    totalTime*: float
    frameWidth*: int
    frameHeight*: int

proc project*[UniT, AttrT](entity: var Entity[UniT, AttrT], left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat) =
  entity.uniforms.u_matrix.project(left, right, bottom, top, near, far)

proc project*[UniT, AttrT](entity: var Entity[UniT, AttrT], fieldOfView: GLfloat, aspect: GLfloat, near: GLfloat, far: GLfloat) =
  entity.uniforms.u_matrix.project(fieldOfView, aspect, near, far)

proc translate*[UniT, AttrT](entity: var Entity[UniT, AttrT], x: GLfloat, y: GLfloat, z: GLfloat) =
  entity.uniforms.u_matrix.translate(x, y, z)

proc scale*[UniT, AttrT](entity: var Entity[UniT, AttrT], x: GLfloat, y: GLfloat, z: GLfloat) =
  entity.uniforms.u_matrix.scale(x, y, z)

proc rotateX*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateX(angle)

proc rotateY*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateY(angle)

proc rotateZ*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateZ(angle)

proc invert*[UniT, AttrT](entity: var Entity[UniT, AttrT], cam: Mat4x4[GLfloat]) =
  entity.uniforms.u_matrix.invert(cam)

proc degToRad*(degrees: GLfloat): GLfloat =
  (degrees * math.PI) / 180f

# textured 3D entity

const threeDTextureVertexShader* =
  """
  #version 330
  uniform mat4 u_matrix;
  in vec4 a_position;
  in vec2 a_texcoord;
  out vec2 v_texcoord;
  void main()
  {
    gl_Position = u_matrix * a_position;
    v_texcoord = a_texcoord;
    v_texcoord.y = 1.0 - v_texcoord.y; // flip y axis
  }
  """

const threeDTextureFragmentShader* =
  """
  #version 330
  precision mediump float;
  uniform sampler2D u_texture;
  in vec2 v_texcoord;
  out vec4 outColor;
  void main()
  {
    outColor = texture(u_texture, v_texcoord);
  }
  """

