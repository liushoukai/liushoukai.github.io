---
layout: post
title:  xmodem、ymodem、zmodem
categories: linux
tags: xmodem ymodem zmodem
---

### XMODEM
Xmodem is one of the most widely used file transfer protocols. The original Xmodem protocol uses 128-byte packets and a simple "checksum" method of error detection. A later enhancement, Xmodem-CRC, uses a more secure Cyclic Redundancy Check (CRC) method for error detection. Xmodem protocol always attempts to use CRC first. If the sender does not acknowledge the requests for CRC, the receiver shifts to the checksum mode and continues its request for transmission.Xmodem-1KXmodem 1K is essentially Xmodem CRC with 1K (1024 byte) packets. On some systems and bulletin boards it may also be referred to as Ymodem. Some communication software programs, most notably Procomm Plus 1.x, also list Xmodem-1K as Ymodem. Procomm Plus 2.0 no longer refers to Xmodem-1K as Ymodem.

### YMODEM
Ymodem is essentially Xmodem 1K that allows multiple batch file transfer. On some systems it is listed as Ymodem Batch.Ymodem-gYmodem-g is a variant of Ymodem. It is designed to be used with modems that support error control. This protocol does not provide software error correction or recovery, but expects the modem to provide the service. It is a streaming protocol that sends and receives 1K packets in a continuous stream until instructed to stop. It does not wait for positive acknowledgement after each block is sent, but rather sends blocks in rapid succession. If any block is unsuccessfully transferred, the entire transfer is canceled.

### ZMODEM
Zmodem is generally the best protocol to use if the electronic service you are calling supports it. Zmodem has two significant features: it is extremely efficient and it provides crash recovery.Like Ymodem-g, Zmodem does not wait for positive acknowledgement after each block is sent, but rather sends blocks in rapid succession. If a Zmodem transfer is canceled or interrupted for any reason, the transfer can be resurrected later and the previously transferred information need not be resent.
