enum LEDController {
  static var ledPin: gpio_num_t = gpio_num_t(2)
  static var switchPin: gpio_num_t = gpio_num_t(3)
  static var ledState: Bool = false
  
  static func initialize() {
    gpio_set_direction(ledPin, GPIO_MODE_OUTPUT)
    gpio_set_direction(switchPin, GPIO_MODE_INPUT)

    ledOff()
  }
  
  static func ledOn() {
    gpio_set_level(ledPin, 1)
  }
  
  static func ledOff() {
    gpio_set_level(ledPin, 0)
  }

  static func setLED(state: Bool) {
    ledState = state
    if state {
      ledOn()
    } else {
      ledOff()
    }
  }

  static func getLED() -> Bool {
    return ledState
  }


  static func getSwitch() -> Bool {
    return gpio_get_level(switchPin) == 0
  }

  static func waitUntilSwitchRelease() {
    while getSwitch() {
      sleep(milliseconds: 100)
    }
  }
  
  static func sleep(milliseconds: Int) {
    let tickRateHz: UInt32 = 1000 / UInt32(configTICK_RATE_HZ)
    let blinkDelayMs: UInt32 = UInt32(milliseconds)
    vTaskDelay(blinkDelayMs / tickRateHz)
  }
}

@_cdecl("app_main")
func app_main() {
  print("Hello, Embedded Swift! 🎉")

  typealias Board = LEDController

  Board.initialize()

  while true {
    if Board.getSwitch() {
      Board.waitUntilSwitchRelease()  // 스위치가 떼어질 때까지 대기

      let ledState = Board.getLED() // 현재 LED 상태 가져옴
      Board.setLED(state: !ledState)      // 상태 반전

      print(ledState ? "Switch Pressed - \tLED OFF 🔅" : "Switch Pressed - LED ON 💡")
    }

    Board.sleep(milliseconds: 100) // CPU 과점유(watchdog trigger) 방지
  }
}
