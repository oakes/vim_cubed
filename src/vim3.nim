import nimgl/glfw
import common
from core import nil
from paravim import nil
from os import nil

var game = Game()

var
  isDragging: bool = false
  mousex: float
  mousey: float
  mouseposx: int32
  mouseposy: int32
  windowx: int32
  windowy: int32
  init_mx: int32
  init_my: int32
  relative_mx: int32
  relative_my:int32

proc keyCallback(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32) {.cdecl.} =
  paravim.keyCallback(window, key, scancode, action, mods)

proc charCallback(window: GLFWWindow, codepoint: uint32) {.cdecl.} =
  paravim.charCallback(window, codepoint)

proc frameSizeCallback(window: GLFWWindow, width: int32, height: int32) {.cdecl.} =
  game.frameWidth = width
  game.frameHeight = height

proc mouseClickCallback(window: GLFWWindow, button: int32, action: int32, mods: int32) {.cdecl.} = 
  window.getCursorPos(mousex.addr, mousey.addr)
  if button == 0 and action == GLFWPress:
    isDragging = true
    mouseposx = mousex.int32
    mouseposy = mousey.int32
    if init_mx == 0 and init_my == 0:
      init_mx = mouseposx
      init_my = mouseposy
  if button == 0 and action == GLFWRelease:
    isDragging = false
    init_mx = 0
    init_my = 0

proc mouseMoveCallback(window: GLFWWindow, xpos: float, ypos: float) {.cdecl.} =
  if isDragging:
    relative_mx = xpos.int32
    relative_my = ypos.int32

when isMainModule:
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)
  glfwWindowHint(GLFWDecorated, GLFWFalse)
  glfwWindowHint(GLFWTransparentFramebuffer, GLFWTrue)

  let w: GLFWWindow = glfwCreateWindow(768, 768, "Vim³ - You can begin by typing `:e path/to/myfile.txt`")
  if w == nil:
    quit(-1)

  w.makeContextCurrent()
  glfwSwapInterval(1)

  discard w.setKeyCallback(keyCallback)
  discard w.setCharCallback(charCallback)
  discard w.setFramebufferSizeCallback(frameSizeCallback)
  discard w.setMouseButtonCallback(mouseClickCallback)
  discard w.setCursorPosCallback(mouseMoveCallback)

  var width, height: int32
  w.getFramebufferSize(width.addr, height.addr)
  w.frameSizeCallback(width, height)

  let params = os.commandLineParams()
  paravim.init(game, w, params)
  core.init(game)

  game.totalTime = glfwGetTime()

  while not w.windowShouldClose:
    let ts = glfwGetTime()
    game.deltaTime = ts - game.totalTime
    game.totalTime = ts
    core.tick(game)

    if isDragging:
      w.getWindowPos(windowx.addr, windowy.addr)
      w.setWindowPos(windowx+relative_mx-init_mx, windowy+relative_my-init_my)

    w.swapBuffers()
    glfwPollEvents()

  w.destroyWindow()
  glfwTerminate()
