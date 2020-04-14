import nimgl/glfw
import common
from core import nil
from paravim import nil
from os import nil

var game = Game()

proc keyCallback(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32) {.cdecl.} =
  paravim.keyCallback(window, key, scancode, action, mods)

proc charCallback(window: GLFWWindow, codepoint: uint32) {.cdecl.} =
  paravim.charCallback(window, codepoint)

proc frameSizeCallback(window: GLFWWindow, width: int32, height: int32) {.cdecl.} =
  game.frameWidth = width
  game.frameHeight = height

when isMainModule:
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  let w: GLFWWindow = glfwCreateWindow(1024, 768, "Vim³ - You can begin by typing `:e path/to/myfile.txt`")
  if w == nil:
    quit(-1)

  w.makeContextCurrent()
  glfwSwapInterval(1)

  discard w.setKeyCallback(keyCallback)
  discard w.setCharCallback(charCallback)
  discard w.setFramebufferSizeCallback(frameSizeCallback)

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
    w.swapBuffers()
    glfwPollEvents()

  w.destroyWindow()
  glfwTerminate()
