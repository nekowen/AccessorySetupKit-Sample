// M5StickC Plus -> BLE Keyboard
// Button A を押したら「iOSDC Japan 2025」を入力

#include <M5StickCPlus.h>
#include <BleKeyboard.h>

// デバイス名/メーカー名は任意で変更可
BleKeyboard bleKeyboard("BLE-Demo", "", 100);

static void drawScreen(bool connected) {
  M5.Lcd.fillScreen(BLACK);
  M5.Lcd.setRotation(1);
  M5.Lcd.setTextSize(2);
  M5.Lcd.setTextColor(WHITE, BLACK);

  M5.Lcd.setCursor(4, 6);
  M5.Lcd.print("BLE-Demo");

  M5.Lcd.setCursor(4, 28);
  
  M5.Lcd.print(connected ? "Connected" : "Not connected");

  M5.Lcd.setCursor(4, 80);
  M5.Lcd.print("A Button: type text");
}

void setup() {
  M5.begin(true, true, true);
  M5.Axp.ScreenBreath(100);
  drawScreen(false);

  // BLE Keyboard 開始
  bleKeyboard.begin();
}

void loop() {
  M5.update();

  // 接続状態の表示を反映
  static bool lastConnected = false;
  bool connected = bleKeyboard.isConnected();
  if (connected != lastConnected) {
    lastConnected = connected;
    drawScreen(connected);
  }

  // A ボタンで送信
  if (M5.BtnA.wasPressed() && connected) {
    bleKeyboard.print("iOSDC Japan 2025");
    bleKeyboard.write(KEY_RETURN);
  }

  delay(10);
}

