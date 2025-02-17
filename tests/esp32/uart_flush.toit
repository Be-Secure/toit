// Copyright (C) 2022 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/LICENSE file.

/**
Tests reading and writing of the UART baud rate.

Setup:
Connect pin 18 to pin 19, optionally with a 330 Ohm resistor to avoid short circuits.
Connect pin 26 to pin 33, optionally with a resistor.
*/

import expect show *
import gpio
import uart
import writer

RX1 := 18
TX1 := 26
RX2 := 33
TX2 := 19

main:
  succeeded := false
  pin_rx1 := gpio.Pin RX1
  pin_tx1 := gpio.Pin TX1
  pin_rx2 := gpio.Pin RX2
  pin_tx2 := gpio.Pin TX2
  for i := 0; i < 2; i++:
    port1 := uart.Port
        --rx=pin_rx1
        --tx=pin_tx1
        --baud_rate=1200

    port2 := uart.Port
        --rx=pin_rx2
        --tx=pin_tx2
        --baud_rate=1200

    TEST_STR ::= "toit toit toit toit"
    done := false
    before := 0
    after := 0
    task::
      print "writing to slow port"
      writer := writer.Writer port1
      writer.write TEST_STR
      before = Time.monotonic_us
      port1.flush
      after = Time.monotonic_us
      print "flush took $(after - before) us"
      done = true

    woken := []
    while not done:
      woken.add Time.monotonic_us
      sleep --ms=10

    // While we were waiting for port1 to flush we were woken several times.
    expect woken.size > 5

    // We make sure that the medium entry was while port1 was flushing.
    expect before < woken[woken.size / 2] < after

    diff := after - before
    expect diff > 50_000

    // When the baud rate is too low we seem to have problems reading... :(
    // Generally, it's enough to do a second round.
    // https://github.com/espressif/esp-idf/issues/9397
    data := port2.read
    // expect_equals TEST_STR data.to_string_non_throwing
    if TEST_STR != data.to_string_non_throwing:
      print "***********************************  NOT EQUAL"
    else:
      succeeded = true
      break

    port1.close
    port2.close

  expect succeeded

  pin_rx1.close
  pin_tx1.close
  pin_rx2.close
  pin_tx2.close
