# CryptoLab: Encryption Algorithms Simulator 🔐

## 📌 Project Overview
This repository contains a comprehensive, cross-platform Flutter application designed to demonstrate and simulate classical and modern cryptography algorithms[cite: 3]. Built as an educational tool (Lab 06), it features a Material 3 user interface and implements complex encryption, decryption, and cryptanalysis techniques entirely from scratch in Dart[cite: 3].

## 🚀 Supported Algorithms & Features

### Classical Cryptography
* **Caesar Cipher:** Includes standard encryption and a brute-force decryption mode that automatically finds the key using English letter frequency scoring[cite: 3].
* **Mono-Alphabetic Substitution:** Supports key-based encryption/decryption and an advanced automated decryption mode using Frequency Analysis and Hill Climbing algorithms[cite: 3].
* **Vigenère Cipher:** Features standard encryption and an auto-decrypt mode that estimates key length using the Index of Coincidence (IC) and recovers the key[cite: 3].
* **Playfair Cipher:** Implements the classic digraph substitution cipher with support for both 5x5 (I/J combined) and 6x6 (alphanumeric) matrices[cite: 3].

### Modern Symmetric-Key Ciphers
* **DES (Data Encryption Standard):** Full custom implementation including Key Expansion, Feistel network, S-Boxes, and Permutation tables[cite: 3]. Supports both ECB and CBC operation modes with PKCS#7 padding[cite: 3].
* **AES (Advanced Encryption Standard):** Complete implementation supporting 128, 192, and 256-bit key sizes[cite: 3]. Includes custom Galois Field math, SubBytes, ShiftRows, and MixColumns operations[cite: 3]. Supports both ECB and CBC modes[cite: 3].

### Asymmetric Cryptography
* **RSA:** Features complete public/private key pair generation from user-provided prime numbers (p and q)[cite: 3]. Implements BigInt mathematics for secure encryption and decryption of text blocks[cite: 3].

## 🛠️ Tech Stack
* **Framework:** Flutter (Cross-platform support for Android, iOS, Web, Windows, macOS, and Linux)
* **Language:** Dart
* **UI/UX:** Material 3 Design with an intuitive Bottom Navigation Bar[cite: 3]

## ⚙️ Getting Started
1. Clone the repository to your local machine.
2. Run `flutter pub get` in the terminal to install dependencies.
3. Run `flutter run` to launch the application on your preferred device or emulator.

---
*Developed by Ho Ngoc Thien Phuoc.*
