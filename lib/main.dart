import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const CryptoLabApp());
}

class CryptoLabApp extends StatelessWidget {
  const CryptoLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 06 - Encryption Algorithms',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CaesarPage(),
    const MonoAlphabeticPage(),
    const VigenerePage(),
    const PlayfairPage(),
    const DESPage(),
    const AESPage(),
    const RSAPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 06 - Review of Encryption Algorithms'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock),
            label: 'Caesar',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            selectedIcon: Icon(Icons.swap_horizontal_circle),
            label: 'Mono-Alpha',
          ),
          NavigationDestination(
            icon: Icon(Icons.key),
            selectedIcon: Icon(Icons.vpn_key),
            label: 'Vigenère',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on),
            selectedIcon: Icon(Icons.grid_4x4),
            label: 'Playfair',
          ),
          NavigationDestination(
            icon: Icon(Icons.security),
            selectedIcon: Icon(Icons.shield),
            label: 'DES',
          ),
          NavigationDestination(
            icon: Icon(Icons.enhanced_encryption),
            selectedIcon: Icon(Icons.verified_user),
            label: 'AES',
          ),
          NavigationDestination(
            icon: Icon(Icons.vpn_lock),
            selectedIcon: Icon(Icons.lock_person),
            label: 'RSA',
          ),
        ],
      ),
    );
  }
}

// ==================== TASK 1: CAESAR CIPHER ====================
class CaesarPage extends StatefulWidget {
  const CaesarPage({super.key});

  @override
  State<CaesarPage> createState() => _CaesarPageState();
}

class _CaesarPageState extends State<CaesarPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _output = '';
  String _mode = 'decrypt';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Task 1: Caesar Cipher',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'encrypt', label: Text('Encrypt')),
              ButtonSegment(value: 'decrypt', label: Text('Decrypt (Brute Force)')),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _mode = newSelection.first;
                _output = '';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Input Text (Ciphertext/Plaintext)',
              border: OutlineInputBorder(),
              hintText: 'Enter text here (>5000 characters for brute force)...',
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == 'encrypt')
            TextField(
              controller: _keyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Key (0-25)',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _processCaesar,
            icon: const Icon(Icons.play_arrow),
            label: Text(_mode == 'encrypt' ? 'Encrypt' : 'Decrypt (Brute Force)'),
          ),
          const SizedBox(height: 16),
          if (_output.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Output:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _output));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_output),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _processCaesar() {
    String input = _inputController.text;
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text')),
      );
      return;
    }

    if (_mode == 'encrypt') {
      int key = int.tryParse(_keyController.text) ?? 0;
      if (key < 0 || key > 25) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Key must be between 0-25')),
        );
        return;
      }
      setState(() {
        _output = CaesarCipher.encrypt(input, key);
      });
    } else {
      setState(() {
        _output = CaesarCipher.bruteForceDecrypt(input);
      });
    }
  }
}

class CaesarCipher {
  static String encrypt(String plaintext, int key) {
    return _shift(plaintext, key);
  }

  static String decrypt(String ciphertext, int key) {
    return _shift(ciphertext, -key);
  }

  static String _shift(String text, int key) {
    StringBuffer result = StringBuffer();
    key = key % 26;

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (RegExp(r'[A-Z]').hasMatch(char)) {
        int shifted = ((char.codeUnitAt(0) - 65 + key) % 26 + 26) % 26;
        result.write(String.fromCharCode(shifted + 65));
      } else if (RegExp(r'[a-z]').hasMatch(char)) {
        int shifted = ((char.codeUnitAt(0) - 97 + key) % 26 + 26) % 26;
        result.write(String.fromCharCode(shifted + 97));
      } else {
        result.write(char);
      }
    }
    return result.toString();
  }

  static String bruteForceDecrypt(String ciphertext) {
    Map<int, double> scores = {};
    
    for (int key = 0; key < 26; key++) {
      String decrypted = decrypt(ciphertext, key);
      scores[key] = _scoreEnglishText(decrypted);
    }

    int bestKey = 0;
    double bestScore = scores[0]!;
    for (var entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestKey = entry.key;
      }
    }

    String plaintext = decrypt(ciphertext, bestKey);
    return 'Key: $bestKey\n\n$plaintext';
  }

  static double _scoreEnglishText(String text) {
    const Map<String, double> freq = {
      'e': 12.70, 't': 9.06, 'a': 8.17, 'o': 7.51, 'i': 6.97,
      'n': 6.75, 's': 6.33, 'h': 6.09, 'r': 5.99, 'd': 4.25,
      'l': 4.03, 'c': 2.78, 'u': 2.76, 'm': 2.41, 'w': 2.36,
      'f': 2.23, 'g': 2.02, 'y': 1.97, 'p': 1.93, 'b': 1.29,
      'v': 0.98, 'k': 0.77, 'j': 0.15, 'x': 0.15, 'q': 0.10, 'z': 0.07
    };

    double score = 0;
    String lowerText = text.toLowerCase();
    
    for (String char in lowerText.split('')) {
      if (freq.containsKey(char)) {
        score += freq[char]!;
      }
    }

    return score;
  }
}

// ==================== TASK 2: MONO-ALPHABETIC SUBSTITUTION ====================
class MonoAlphabeticPage extends StatefulWidget {
  const MonoAlphabeticPage({super.key});

  @override
  State<MonoAlphabeticPage> createState() => _MonoAlphabeticPageState();
}

class _MonoAlphabeticPageState extends State<MonoAlphabeticPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _output = '';
  String _mode = 'decrypt';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Task 2: Mono-Alphabetic Substitution',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'encrypt', label: Text('Encrypt')),
              ButtonSegment(value: 'decrypt', label: Text('Decrypt (Frequency Analysis)')),
              ButtonSegment(value: 'decrypt_key', label: Text('Decrypt (With Key)')),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _mode = newSelection.first;
                _output = '';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Input Text',
              border: OutlineInputBorder(),
              hintText: 'Enter text here (>5000 characters recommended)...',
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == 'encrypt' || _mode == 'decrypt_key')
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Substitution Key (26 unique letters)',
                border: OutlineInputBorder(),
                hintText: 'e.g., bcdefghijklmnopqrstuvwxyza',
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processSubstitution,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_mode == 'encrypt' ? 'Encrypt' : (_mode == 'decrypt_key' ? 'Decrypt (With Key)' : 'Decrypt (Frequency Analysis)')),
          ),
          const SizedBox(height: 16),
          if (_output.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Output:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _output));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_output),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _processSubstitution() async {
    String input = _inputController.text;
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_mode == 'encrypt') {
        String key = _keyController.text.toLowerCase();
        if (!_isValidSubstitutionKey(key)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid key! Must be 26 unique lowercase letters'),
            ),
          );
          return;
        }
        setState(() {
          _output = SubstitutionCipher.encrypt(input, key);
        });
      } else if (_mode == 'decrypt_key') {
        String key = _keyController.text.toLowerCase();
        if (!_isValidSubstitutionKey(key)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid key! Must be 26 unique lowercase letters'),
            ),
          );
          return;
        }
        setState(() {
          _output = SubstitutionCipher.decrypt(input, key);
        });
      } else {
        String result = await SubstitutionCipher.frequencyAnalysisDecrypt(input);
        setState(() {
          _output = result;
        });
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  bool _isValidSubstitutionKey(String key) {
    if (key.length != 26) return false;
    Set<String> chars = {};
    for (String char in key.split('')) {
      if (!RegExp(r'[a-z]').hasMatch(char)) return false;
      if (chars.contains(char)) return false;
      chars.add(char);
    }
    return true;
  }
}

class SubstitutionCipher {
  static const String alphabet = 'abcdefghijklmnopqrstuvwxyz';

  static String encrypt(String plaintext, String key) {
    StringBuffer result = StringBuffer();
    String lowerText = plaintext.toLowerCase();

    for (String char in lowerText.split('')) {
      int index = alphabet.indexOf(char);
      if (index != -1) {
        result.write(key[index]);
      } else {
        result.write(char);
      }
    }

    return result.toString();
  }

  static String decrypt(String ciphertext, String key) {
    StringBuffer result = StringBuffer();
    String lowerText = ciphertext.toLowerCase();

    for (String char in lowerText.split('')) {
      int index = key.indexOf(char);
      if (index != -1) {
        result.write(alphabet[index]);
      } else {
        result.write(char);
      }
    }

    return result.toString();
  }

  static Future<String> frequencyAnalysisDecrypt(String ciphertext) async {
    const String englishFreqOrder = 'etaoinshrdlcumwfgypbvkjxqz';
    
    Map<String, int> frequency = {};
    String lowerText = ciphertext.toLowerCase();
    
    for (String char in lowerText.split('')) {
      if (RegExp(r'[a-z]').hasMatch(char)) {
        frequency[char] = (frequency[char] ?? 0) + 1;
      }
    }

    List<MapEntry<String, int>> sortedFreq = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Map<String, String> mapping = {};
    for (int i = 0; i < sortedFreq.length && i < englishFreqOrder.length; i++) {
      mapping[sortedFreq[i].key] = englishFreqOrder[i];
    }

    Set<String> usedChars = Set.from(mapping.values);
    int englishIndex = 0;
    for (String char in alphabet.split('')) {
      if (!mapping.containsKey(char)) {
        while (usedChars.contains(englishFreqOrder[englishIndex])) {
          englishIndex++;
        }
        mapping[char] = englishFreqOrder[englishIndex];
        usedChars.add(englishFreqOrder[englishIndex]);
        englishIndex++;
      }
    }

    double bestScore = _scoreText(_applyMapping(lowerText, mapping));
    Map<String, String> bestMapping = Map.from(mapping);

    for (int iteration = 0; iteration < 1000; iteration++) {
      List<String> keys = mapping.keys.toList();
      int i = Random().nextInt(keys.length);
      int j = Random().nextInt(keys.length);
      
      String temp = mapping[keys[i]]!;
      mapping[keys[i]] = mapping[keys[j]]!;
      mapping[keys[j]] = temp;

      double score = _scoreText(_applyMapping(lowerText, mapping));
      
      if (score > bestScore) {
        bestScore = score;
        bestMapping = Map.from(mapping);
      } else {
        temp = mapping[keys[i]]!;
        mapping[keys[i]] = mapping[keys[j]]!;
        mapping[keys[j]] = temp;
      }
    }

    String plaintext = _applyMapping(lowerText, bestMapping);
    String mappingStr = _formatMapping(bestMapping);

    return 'Score: ${bestScore.toStringAsFixed(2)}\n\nMapping:\n$mappingStr\n\nPlaintext:\n$plaintext';
  }

  static String _applyMapping(String text, Map<String, String> mapping) {
    StringBuffer result = StringBuffer();
    for (String char in text.split('')) {
      result.write(mapping[char] ?? char);
    }
    return result.toString();
  }

  static String _formatMapping(Map<String, String> mapping) {
    StringBuffer result = StringBuffer();
    for (String char in alphabet.split('')) {
      result.write('$char -> ${mapping[char] ?? '?'}  ');
      if (alphabet.indexOf(char) % 13 == 12) result.write('\n');
    }
    return result.toString();
  }

  static double _scoreText(String text) {
    const Map<String, double> commonBigrams = {
      'th': 3.56, 'he': 3.07, 'in': 2.43, 'er': 2.05, 'an': 1.99,
      'on': 1.76, 're': 1.76, 'at': 1.49, 'en': 1.45, 'nd': 1.35,
      'ti': 1.34, 'es': 1.34, 'or': 1.28, 'te': 1.20, 'of': 1.17,
      'ed': 1.17, 'is': 1.13, 'it': 1.12, 'al': 1.09, 'ar': 1.07,
      'st': 1.05, 'to': 1.04, 'nt': 1.04, 'ng': 0.95, 've': 0.95,
    };

    double score = 0;
    for (int i = 0; i < text.length - 1; i++) {
      String bigram = text.substring(i, i + 2);
      if (commonBigrams.containsKey(bigram)) {
        score += commonBigrams[bigram]!;
      }
    }

    return score;
  }
}

// ==================== TASK 3: VIGENÈRE CIPHER ====================
class VigenerePage extends StatefulWidget {
  const VigenerePage({super.key});

  @override
  State<VigenerePage> createState() => _VigenerePageState();
}

class _VigenerePageState extends State<VigenerePage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _output = '';
  String _mode = 'decrypt';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Task 3: Vigenère Cipher',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'encrypt', label: Text('Encrypt')),
              ButtonSegment(value: 'decrypt', label: Text('Decrypt (Kasiski/IC)')),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _mode = newSelection.first;
                _output = '';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Input Text',
              border: OutlineInputBorder(),
              hintText: 'Enter text here (>5000 characters recommended)...',
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == 'encrypt')
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Key (letters only)',
                border: OutlineInputBorder(),
                hintText: 'e.g., SECRET',
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processVigenere,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_mode == 'encrypt' ? 'Encrypt' : 'Decrypt (Auto-detect key)'),
          ),
          const SizedBox(height: 16),
          if (_output.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Output:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _output));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_output),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _processVigenere() async {
    String input = _inputController.text;
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_mode == 'encrypt') {
        String key = _keyController.text;
        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(key)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Key must contain only letters')),
          );
          return;
        }
        setState(() {
          _output = VigenereCipher.encrypt(input, key);
        });
      } else {
        String result = await VigenereCipher.autoDecrypt(input);
        setState(() {
          _output = result;
        });
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

class VigenereCipher {
  static String encrypt(String plaintext, String key) {
    StringBuffer result = StringBuffer();
    String keyUpper = key.toUpperCase();
    String textUpper = plaintext.toUpperCase();
    int keyIndex = 0;

    for (int i = 0; i < plaintext.length; i++) {
      String char = plaintext[i];
      String upperChar = textUpper[i];
      
      if (RegExp(r'[A-Z]').hasMatch(upperChar)) {
        int shift = keyUpper.codeUnitAt(keyIndex % keyUpper.length) - 65;
        int encrypted = ((upperChar.codeUnitAt(0) - 65 + shift) % 26 + 65);
        
        if (RegExp(r'[a-z]').hasMatch(char)) {
          result.write(String.fromCharCode(encrypted + 32));
        } else {
          result.write(String.fromCharCode(encrypted));
        }
        keyIndex++;
      } else {
        result.write(char);
      }
    }

    return result.toString();
  }

  static String decrypt(String ciphertext, String key) {
    StringBuffer result = StringBuffer();
    String keyUpper = key.toUpperCase();
    String textUpper = ciphertext.toUpperCase();
    int keyIndex = 0;

    for (int i = 0; i < ciphertext.length; i++) {
      String char = ciphertext[i];
      String upperChar = textUpper[i];
      
      if (RegExp(r'[A-Z]').hasMatch(upperChar)) {
        int shift = keyUpper.codeUnitAt(keyIndex % keyUpper.length) - 65;
        int decrypted = ((upperChar.codeUnitAt(0) - 65 - shift + 26) % 26 + 65);
        
        if (RegExp(r'[a-z]').hasMatch(char)) {
          result.write(String.fromCharCode(decrypted + 32));
        } else {
          result.write(String.fromCharCode(decrypted));
        }
        keyIndex++;
      } else {
        result.write(char);
      }
    }

    return result.toString();
  }

  static Future<String> autoDecrypt(String ciphertext) async {
    String cleanText = ciphertext.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    
    if (cleanText.length < 20) {
      return 'Error: Text too short for analysis (need at least 20 letters)';
    }

    int estimatedKeyLength = _estimateKeyLength(cleanText);
    String key = _findKey(cleanText, estimatedKeyLength);
    String plaintext = decrypt(ciphertext, key);
    
    return 'Estimated Key Length: $estimatedKeyLength\nKey: $key\n\nPlaintext:\n$plaintext';
  }

  static int _estimateKeyLength(String text) {
    const double englishIC = 0.067;
    Map<int, double> icScores = {};

    for (int keyLength = 1; keyLength <= 20; keyLength++) {
      double avgIC = 0;
      
      for (int i = 0; i < keyLength; i++) {
        StringBuffer subset = StringBuffer();
        for (int j = i; j < text.length; j += keyLength) {
          subset.write(text[j]);
        }
        avgIC += _calculateIC(subset.toString());
      }
      
      icScores[keyLength] = avgIC / keyLength;
    }

    int bestLength = 1;
    double bestDiff = 1.0;
    
    for (var entry in icScores.entries) {
      double diff = (entry.value - englishIC).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestLength = entry.key;
      }
    }

    return bestLength;
  }

  static double _calculateIC(String text) {
    if (text.length < 2) return 0;
    
    Map<String, int> freq = {};
    for (String char in text.split('')) {
      freq[char] = (freq[char] ?? 0) + 1;
    }

    double sum = 0;
    for (int count in freq.values) {
      sum += count * (count - 1);
    }

    return sum / (text.length * (text.length - 1));
  }

  static String _findKey(String text, int keyLength) {
    StringBuffer key = StringBuffer();

    for (int i = 0; i < keyLength; i++) {
      StringBuffer subset = StringBuffer();
      for (int j = i; j < text.length; j += keyLength) {
        subset.write(text[j]);
      }
      
      int bestShift = _findBestShift(subset.toString());
      key.write(String.fromCharCode(bestShift + 65));
    }

    return key.toString();
  }

  static int _findBestShift(String text) {
    double bestScore = -999999;
    int bestShift = 0;

    for (int shift = 0; shift < 26; shift++) {
      String shifted = _shiftText(text, shift);
      double score = _scoreEnglishFrequency(shifted);
      
      if (score > bestScore) {
        bestScore = score;
        bestShift = shift;
      }
    }

    return (26 - bestShift) % 26;
  }

  static String _shiftText(String text, int shift) {
    StringBuffer result = StringBuffer();
    for (String char in text.split('')) {
      int shifted = ((char.codeUnitAt(0) - 65 + shift) % 26 + 65);
      result.write(String.fromCharCode(shifted));
    }
    return result.toString();
  }

  static double _scoreEnglishFrequency(String text) {
    const Map<String, double> freq = {
      'E': 12.70, 'T': 9.06, 'A': 8.17, 'O': 7.51, 'I': 6.97,
      'N': 6.75, 'S': 6.33, 'H': 6.09, 'R': 5.99, 'D': 4.25,
      'L': 4.03, 'C': 2.78, 'U': 2.76, 'M': 2.41, 'W': 2.36,
      'F': 2.23, 'G': 2.02, 'Y': 1.97, 'P': 1.93, 'B': 1.29,
      'V': 0.98, 'K': 0.77, 'J': 0.15, 'X': 0.15, 'Q': 0.10, 'Z': 0.07
    };

    double score = 0;
    for (String char in text.split('')) {
      score += freq[char] ?? 0;
    }

    return score;
  }
}

// ====================================================================================
// ==================== TASK 4: DES IMPLEMENTATION ====================================
// ====================================================================================

class DESPage extends StatefulWidget {
  const DESPage({super.key});

  @override
  State<DESPage> createState() => _DESPageState();
}

class _DESPageState extends State<DESPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _ivController = TextEditingController();
  String _output = '';
  String _mode = 'encrypt';
  String _operationMode = 'ECB';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Task 4: DES Encryption',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'encrypt', label: Text('Encrypt')),
              ButtonSegment(value: 'decrypt', label: Text('Decrypt')),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _mode = newSelection.first;
                _output = '';
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _operationMode,
            decoration: const InputDecoration(
              labelText: 'Operation Mode',
              border: OutlineInputBorder(),
            ),
            items: ['ECB', 'CBC']
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _operationMode = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: _mode == 'encrypt' ? 'Plaintext' : 'Ciphertext (hex)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyController,
            decoration: const InputDecoration(
              labelText: 'Key (16 hex characters)',
              border: OutlineInputBorder(),
              hintText: '0123456789ABCDEF',
            ),
          ),
          const SizedBox(height: 16),
          if (_operationMode != 'ECB')
            TextField(
              controller: _ivController,
              decoration: const InputDecoration(
                labelText: 'IV (16 hex characters)',
                border: OutlineInputBorder(),
                hintText: 'FEDCBA9876543210',
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processDES,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_mode == 'encrypt' ? 'Encrypt with DES' : 'Decrypt with DES'),
          ),
          const SizedBox(height: 16),
          if (_output.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Output:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _output));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_output),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _processDES() async {
    String input = _inputController.text;
    String keyHex = _keyController.text.trim();
    
    if (input.isEmpty || keyHex.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text and key')),
      );
      return;
    }

    if (keyHex.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Key must be 16 hex characters (8 bytes)')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_mode == 'encrypt') {
        List<int> plainBytes = utf8.encode(input);
        List<int> keyBytes = DESCrypto.hexToBytes(keyHex);
        List<int> cipherBytes;

        if (_operationMode == 'ECB') {
          // Sử dụng hàm đã sửa
          cipherBytes = DESCrypto.encryptECB_CrypToolFix(plainBytes, keyBytes);
        } else {
          String ivHex = _ivController.text.trim();
          List<int> ivBytes;
          
          if (ivHex.isEmpty) {
           ivBytes = List.filled(8, 0); // 8 bytes, tất cả là 0
            ivHex = '0000000000000000';   // Hex của IV toàn 0
          } else {
            if (ivHex.length != 16) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IV must be 16 hex characters')),
              );
              setState(() => _isProcessing = false);
              return;
            }
            ivBytes = DESCrypto.hexToBytes(ivHex);
          }
          

          cipherBytes = DESCrypto.encryptCBC_CrypToolFix(plainBytes, keyBytes, ivBytes);
          
          setState(() {
            _output = 'IV (save this for decryption):\n$ivHex\n\nCiphertext (hex):\n${DESCrypto.bytesToHex(cipherBytes)}';
          });
          return; 
        }

        setState(() {
          _output = 'Ciphertext (hex):\n${DESCrypto.bytesToHex(cipherBytes)}';
        });
      } else {
        List<int> cipherBytes = DESCrypto.hexToBytes(input.replaceAll(RegExp(r'\s'), ''));
        List<int> keyBytes = DESCrypto.hexToBytes(keyHex);
        List<int> plainBytes;

        if (_operationMode == 'ECB') {

          plainBytes = DESCrypto.decryptECB_CrypToolFix(cipherBytes, keyBytes);
        } else {
          String ivHex = _ivController.text.trim();
          if (ivHex.length != 16) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('IV must be 16 hex characters')),
            );
            return;
          }
          List<int> ivBytes = DESCrypto.hexToBytes(ivHex);

          plainBytes = DESCrypto.decryptCBC_CrypToolFix(cipherBytes, keyBytes, ivBytes);
        }

        setState(() {
          _output = 'Plaintext:\n${utf8.decode(plainBytes)}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

// DES Implementation
class DESCrypto {
  static const List<int> IP = [
    58, 50, 42, 34, 26, 18, 10, 2,
    60, 52, 44, 36, 28, 20, 12, 4,
    62, 54, 46, 38, 30, 22, 14, 6,
    64, 56, 48, 40, 32, 24, 16, 8,
    57, 49, 41, 33, 25, 17, 9, 1,
    59, 51, 43, 35, 27, 19, 11, 3,
    61, 53, 45, 37, 29, 21, 13, 5,
    63, 55, 47, 39, 31, 23, 15, 7
  ];

  static const List<int> FP = [
    40, 8, 48, 16, 56, 24, 64, 32,
    39, 7, 47, 15, 55, 23, 63, 31,
    38, 6, 46, 14, 54, 22, 62, 30,
    37, 5, 45, 13, 53, 21, 61, 29,
    36, 4, 44, 12, 52, 20, 60, 28,
    35, 3, 43, 11, 51, 19, 59, 27,
    34, 2, 42, 10, 50, 18, 58, 26,
    33, 1, 41, 9, 49, 17, 57, 25
  ];

  static const List<int> E = [
    32, 1, 2, 3, 4, 5, 4, 5,
    6, 7, 8, 9, 8, 9, 10, 11,
    12, 13, 12, 13, 14, 15, 16, 17,
    16, 17, 18, 19, 20, 21, 20, 21,
    22, 23, 24, 25, 24, 25, 26, 27,
    28, 29, 28, 29, 30, 31, 32, 1
  ];

  static const List<int> P = [
    16, 7, 20, 21, 29, 12, 28, 17,
    1, 15, 23, 26, 5, 18, 31, 10,
    2, 8, 24, 14, 32, 27, 3, 9,
    19, 13, 30, 6, 22, 11, 4, 25
  ];

  static const List<int> PC1 = [
    57, 49, 41, 33, 25, 17, 9,
    1, 58, 50, 42, 34, 26, 18,
    10, 2, 59, 51, 43, 35, 27,
    19, 11, 3, 60, 52, 44, 36,
    63, 55, 47, 39, 31, 23, 15,
    7, 62, 54, 46, 38, 30, 22,
    14, 6, 61, 53, 45, 37, 29,
    21, 13, 5, 28, 20, 12, 4
  ];

  static const List<int> PC2 = [
    14, 17, 11, 24, 1, 5, 3, 28,
    15, 6, 21, 10, 23, 19, 12, 4,
    26, 8, 16, 7, 27, 20, 13, 2,
    41, 52, 31, 37, 47, 55, 30, 40,
    51, 45, 33, 48, 44, 49, 39, 56,
    34, 53, 46, 42, 50, 36, 29, 32
  ];

  static const List<List<List<int>>> SBOX = [
    [[14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7],
     [0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8],
     [4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0],
     [15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13]],
    [[15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10],
     [3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5],
     [0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15],
     [13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9]],
    [[10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8],
     [13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1],
     [13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7],
     [1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12]],
    [[7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15],
     [13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9],
     [10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4],
     [3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14]],
    [[2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9],
     [14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6],
     [4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14],
     [11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3]],
    [[12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11],
     [10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8],
     [9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6],
     [4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13]],
    [[4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1],
     [13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6],
     [1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2],
     [6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12]],
    [[13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7],
     [1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2],
     [7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8],
     [2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11]]
  ];

  static const List<int> SHIFTS = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1];

  static List<int> hexToBytes(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
  }

  static List<int> permute(List<int> input, List<int> table) {
    int outputBits = table.length;
    int outputBytes = (outputBits + 7) ~/ 8;
    List<int> output = List.filled(outputBytes, 0);
    
    for (int i = 0; i < table.length; i++) {
      int inputBitPos = table[i] - 1;
      int inputByteIdx = inputBitPos ~/ 8;
      int inputBitIdx = 7 - (inputBitPos % 8);
      int bit = (input[inputByteIdx] >> inputBitIdx) & 1;
      
      int outputByteIdx = i ~/ 8;
      int outputBitIdx = 7 - (i % 8);
      if (bit == 1) {
        output[outputByteIdx] |= (1 << outputBitIdx);
      }
    }
    
    return output;
  }

  static List<int> xor(List<int> a, List<int> b) {
    List<int> result = [];
    for (int i = 0; i < a.length && i < b.length; i++) {
      result.add(a[i] ^ b[i]);
    }
    return result;
  }

  static List<int> leftShift28(List<int> half, int n) {
    int val = (half[0] << 20) | (half[1] << 12) | (half[2] << 4) | (half[3] >> 4);
    val = ((val << n) | (val >> (28 - n))) & 0x0FFFFFFF;
    
    return [
      (val >> 20) & 0xFF,
      (val >> 12) & 0xFF,
      (val >> 4) & 0xFF,
      (val << 4) & 0xFF
    ];
  }

  static List<List<int>> generateSubkeys(List<int> key) {
    List<int> permutedKey = permute(key, PC1);
    
    List<int> c = permutedKey.sublist(0, 4);
    c[3] &= 0xF0;
    
    List<int> d = List.filled(4, 0);
    d[0] = (permutedKey[3] << 4) & 0xF0;
    d[1] = permutedKey[4];
    d[2] = permutedKey[5];
    d[3] = permutedKey[6] << 4;
    
    List<List<int>> subkeys = [];
    
    for (int round = 0; round < 16; round++) {
      c = leftShift28(c, SHIFTS[round]);
      d = leftShift28(d, SHIFTS[round]);
      
      List<int> cd = List.filled(7, 0);
      cd[0] = c[0];
      cd[1] = c[1];
      cd[2] = c[2];
      cd[3] = (c[3] & 0xF0) | ((d[0] >> 4) & 0x0F);
      cd[4] = ((d[0] << 4) & 0xF0) | ((d[1] >> 4) & 0x0F);
      cd[5] = ((d[1] << 4) & 0xF0) | ((d[2] >> 4) & 0x0F);
      cd[6] = ((d[2] << 4) & 0xF0) | ((d[3] >> 4) & 0x0F);
      
      List<int> subkey = permute(cd, PC2);
      subkeys.add(subkey);
    }
    
    return subkeys;
  }

  static List<int> feistel(List<int> right, List<int> subkey) {
    List<int> expanded = permute(right, E);
    List<int> xored = xor(expanded, subkey);
    
    List<int> sboxOutput = List.filled(4, 0);
    
    for (int i = 0; i < 8; i++) {
      int bitPos = i * 6;
      int val = 0;
      for (int j = 0; j < 6; j++) {
        int byteIdx = (bitPos + j) ~/ 8;
        int bitIdx = 7 - ((bitPos + j) % 8);
        int bit = (xored[byteIdx] >> bitIdx) & 1;
        val = (val << 1) | bit;
      }
      
      int row = ((val >> 4) & 0x02) | (val & 0x01);
      int col = (val >> 1) & 0x0F;
      
      int sValue = SBOX[i][row][col];
      
      int byteIndex = i ~/ 2;
      if (i % 2 == 0) {
        sboxOutput[byteIndex] |= (sValue << 4);
      } else {
        sboxOutput[byteIndex] |= sValue;
      }
    }
    
    return permute(sboxOutput, P);
  }

  static List<int> desBlock(List<int> block, List<List<int>> subkeys, bool encrypt) {
    List<int> permuted = permute(block, IP);
    
    List<int> left = permuted.sublist(0, 4);
    List<int> right = permuted.sublist(4, 8);
    
    for (int round = 0; round < 16; round++) {
      List<int> temp = List.from(right);
      int keyIndex = encrypt ? round : (15 - round);
      List<int> fResult = feistel(right, subkeys[keyIndex]);
      right = xor(left, fResult);
      left = temp;
    }
    
    List<int> combined = right + left;
    return permute(combined, FP);
  }

  // Hàm padding PKCS#7 chuẩn
  static List<int> addPadding(List<int> data) {
    int padding = 8 - (data.length % 8);
    return data + List.filled(padding, padding);
  }

  // Hàm gỡ padding PKCS#7 chuẩn
  static List<int> removePadding(List<int> data) {
    if (data.isEmpty) return data;
    int padding = data.last;
    if (padding < 1 || padding > 8) return data;

    if (data.length < padding) return data; 
    for (int i = data.length - padding; i < data.length; i++) {
      if (data[i] != padding) return data; 
    }
    return data.sublist(0, data.length - padding);
  }



  static List<int> encryptECB_CrypToolFix(List<int> plaintext, List<int> key) {
    List<List<int>> subkeys = generateSubkeys(key);
 
    List<int> padded = addPadding(plaintext);

    List<int> doublePadded = addPadding(padded);

    List<int> ciphertext = [];

    for (int i = 0; i < doublePadded.length; i += 8) {
      List<int> block = doublePadded.sublist(i, i + 8);
      List<int> encrypted = desBlock(block, subkeys, true);
      ciphertext.addAll(encrypted);
    }

    return ciphertext;
  }

  static List<int> decryptECB_CrypToolFix(List<int> ciphertext, List<int> key) {
    List<List<int>> subkeys = generateSubkeys(key);
    List<int> plaintext = [];

    for (int i = 0; i < ciphertext.length; i += 8) {
      List<int> block = ciphertext.sublist(i, i + 8);
      List<int> decrypted = desBlock(block, subkeys, false);
      plaintext.addAll(decrypted);
    }


    List<int> unpadded1 = removePadding(plaintext);

    List<int> unpadded2 = removePadding(unpadded1);
    
    return unpadded2;
  }

  static List<int> encryptCBC_CrypToolFix(List<int> plaintext, List<int> key, List<int> iv) {
    List<List<int>> subkeys = generateSubkeys(key);
    

    List<int> padded = addPadding(plaintext);
    List<int> doublePadded = addPadding(padded);
    
    List<int> ciphertext = [];
    List<int> prevBlock = iv;

    for (int i = 0; i < doublePadded.length; i += 8) {
      List<int> block = doublePadded.sublist(i, i + 8);
      List<int> xored = xor(block, prevBlock);
      List<int> encrypted = desBlock(xored, subkeys, true);
      ciphertext.addAll(encrypted);
      prevBlock = encrypted;
    }

    return ciphertext;
  }

  static List<int> decryptCBC_CrypToolFix(List<int> ciphertext, List<int> key, List<int> iv) {
    List<List<int>> subkeys = generateSubkeys(key);
    List<int> plaintext = [];
    List<int> prevBlock = iv;

    for (int i = 0; i < ciphertext.length; i += 8) {
      List<int> block = ciphertext.sublist(i, i + 8);
      List<int> decrypted = desBlock(block, subkeys, false);
      List<int> xored = xor(decrypted, prevBlock);
      plaintext.addAll(xored);
      prevBlock = block;
    }

    List<int> unpadded1 = removePadding(plaintext);

    List<int> unpadded2 = removePadding(unpadded1);

    return unpadded2;
  }


}


// ====================================================================================
// ==================== TASK 5: AES IMPLEMENTATION ====================================
// ====================================================================================

class AESPage extends StatefulWidget {
  const AESPage({super.key});

  @override
  State<AESPage> createState() => _AESPageState();
}

class _AESPageState extends State<AESPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _ivController = TextEditingController();
  String _output = '';
  String _mode = 'encrypt';
  String _operationMode = 'ECB';
  String _keySize = '128';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Task 5: AES Encryption',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'encrypt', label: Text('Encrypt')),
              ButtonSegment(value: 'decrypt', label: Text('Decrypt')),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _mode = newSelection.first;
                _output = '';
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _keySize,
            decoration: const InputDecoration(
              labelText: 'Key Size',
              border: OutlineInputBorder(),
            ),
            items: ['128', '192', '256']
                .map((size) => DropdownMenuItem(value: size, child: Text('$size-bit')))
                .toList(),
            onChanged: (value) {
              setState(() {
                _keySize = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _operationMode,
            decoration: const InputDecoration(
              labelText: 'Operation Mode',
              border: OutlineInputBorder(),
            ),
            items: ['ECB', 'CBC']
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _operationMode = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: _mode == 'encrypt' ? 'Plaintext' : 'Ciphertext (hex)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyController,
            decoration: InputDecoration(
              labelText: 'Key (${int.parse(_keySize) ~/ 4} hex characters)',
              border: const OutlineInputBorder(),
              hintText: _keySize == '128'
                  ? '2b7e151628aed2a6abf7158809cf4f3c'
                  : _keySize == '192'
                  ? '8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b'
                  : '603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4',
            ),
          ),
          const SizedBox(height: 16),
          if (_operationMode != 'ECB')
            TextField(
              controller: _ivController,
              decoration: const InputDecoration(
                labelText: 'IV (32 hex characters)',
                border: OutlineInputBorder(),
                hintText: '000102030405060708090a0b0c0d0e0f',
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processAES,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_mode == 'encrypt' ? 'Encrypt with AES' : 'Decrypt with AES'),
          ),
          const SizedBox(height: 16),
          if (_output.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Output:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _output));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_output),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _processAES() async {
    String input = _inputController.text;
    String keyHex = _keyController.text.trim();
    
    if (input.isEmpty || keyHex.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text and key')),
      );
      return;
    }

    int expectedKeyLen = int.parse(_keySize) ~/ 4;
    if (keyHex.length != expectedKeyLen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Key must be $expectedKeyLen hex characters')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_mode == 'encrypt') {
        List<int> plainBytes = utf8.encode(input);
        List<int> keyBytes = AESCrypto.hexToBytes(keyHex);
        List<int> cipherBytes;

        if (_operationMode == 'ECB') {
          cipherBytes = AESCrypto.encryptECB(plainBytes, keyBytes);
        } else {
          String ivHex = _ivController.text.trim();
          List<int> ivBytes;
          
          if (ivHex.isEmpty) {

            ivBytes = List.filled(16, 0); 
            ivHex = '00000000000000000000000000000000';
          } else {
            if (ivHex.length != 32) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IV must be 32 hex characters')),
              );
              setState(() => _isProcessing = false);
              return;
            }
            ivBytes = AESCrypto.hexToBytes(ivHex);
          }
          
          cipherBytes = AESCrypto.encryptCBC(plainBytes, keyBytes, ivBytes);
          
          setState(() {
            _output = 'IV (save this for decryption):\n$ivHex\n\nCiphertext (hex):\n${AESCrypto.bytesToHex(cipherBytes)}';
          });
          return; 
        }

        setState(() {
          _output = 'Ciphertext (hex):\n${AESCrypto.bytesToHex(cipherBytes)}';
        });
      } else {
        List<int> cipherBytes = AESCrypto.hexToBytes(input.replaceAll(RegExp(r'\s'), ''));
        List<int> keyBytes = AESCrypto.hexToBytes(keyHex);
        List<int> plainBytes;

        if (_operationMode == 'ECB') {
          plainBytes = AESCrypto.decryptECB(cipherBytes, keyBytes);
        } else {
          String ivHex = _ivController.text.trim();
          if (ivHex.length != 32) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('IV must be 32 hex characters')),
            );
            return;
          }
          List<int> ivBytes = AESCrypto.hexToBytes(ivHex);
          plainBytes = AESCrypto.decryptCBC(cipherBytes, keyBytes, ivBytes);
        }

        setState(() {
          _output = 'Plaintext:\n${utf8.decode(plainBytes)}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

// AES Implementation
class AESCrypto {
  // S-box
  static const List<int> SBOX = [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
  ];

  // Inverse S-box
  static const List<int> INV_SBOX = [
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
  ];

  // Round constants
  static const List<int> RCON = [
    0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36
  ];

  static List<int> hexToBytes(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  // Galois Field multiplication
  static int gfMul(int a, int b) {
    int p = 0;
    for (int i = 0; i < 8; i++) {
      if ((b & 1) != 0) p ^= a;
      bool hiBitSet = (a & 0x80) != 0;
      a = (a << 1) & 0xFF;
      if (hiBitSet) a ^= 0x1B;
      b >>= 1;
    }
    return p;
  }

  // SubBytes
  static List<List<int>> subBytes(List<List<int>> state) {
    List<List<int>> newState = List.generate(4, (_) => List.filled(4, 0));
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        newState[r][c] = SBOX[state[r][c]];
      }
    }
    return newState;
  }

  static List<List<int>> invSubBytes(List<List<int>> state) {
    List<List<int>> newState = List.generate(4, (_) => List.filled(4, 0));
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        newState[r][c] = INV_SBOX[state[r][c]];
      }
    }
    return newState;
  }

  // ShiftRows
  static List<List<int>> shiftRows(List<List<int>> state) {
    List<List<int>> newState = List.generate(4, (_) => List.filled(4, 0));
    newState[0] = List.from(state[0]);
    newState[1] = [state[1][1], state[1][2], state[1][3], state[1][0]];
    newState[2] = [state[2][2], state[2][3], state[2][0], state[2][1]];
    newState[3] = [state[3][3], state[3][0], state[3][1], state[3][2]];
    return newState;
  }

  static List<List<int>> invShiftRows(List<List<int>> state) {
    List<List<int>> newState = List.generate(4, (_) => List.filled(4, 0));
    newState[0] = List.from(state[0]);
    newState[1] = [state[1][3], state[1][0], state[1][1], state[1][2]];
    newState[2] = [state[2][2], state[2][3], state[2][0], state[2][1]];
    newState[3] = [state[3][1], state[3][2], state[3][3], state[3][0]];
    return newState;
  }

  // MixColumns
  static List<List<int>> mixColumns(List<List<int>> state) {
    List<List<int>> newState = List.generate(4, (_) => List.filled(4, 0));
    for (int c = 0; c < 4; c++) {
      newState[0][c] = gfMul(0x02, state[0][c]) ^ gfMul(0x03, state[1][c]) ^ state[2][c] ^ state[3][c];
      newState[1][c] = state[0][c] ^ gfMul(0x02, state[1][c]) ^ gfMul(0x03, state[2][c]) ^ state[3][c];
      newState[2][c] = state[0][c] ^ state[1][c] ^ gfMul(0x02, state[2][c]) ^ gfMul(0x03, state[3][c]);
      newState[3][c] = gfMul(0x03, state[0][c]) ^ state[1][c] ^ state[2][c] ^ gfMul(0x02, state[3][c]);
    }
    return newState;
  }

  static List<List<int>> invMixColumns(List<List<int>> state) {
    List<List<int>> newState = List.generate(4, (_) => List.filled(4, 0));
    for (int c = 0; c < 4; c++) {
      newState[0][c] = gfMul(0x0e, state[0][c]) ^ gfMul(0x0b, state[1][c]) ^ gfMul(0x0d, state[2][c]) ^ gfMul(0x09, state[3][c]);
      newState[1][c] = gfMul(0x09, state[0][c]) ^ gfMul(0x0e, state[1][c]) ^ gfMul(0x0b, state[2][c]) ^ gfMul(0x0d, state[3][c]);
      newState[2][c] = gfMul(0x0d, state[0][c]) ^ gfMul(0x09, state[1][c]) ^ gfMul(0x0e, state[2][c]) ^ gfMul(0x0b, state[3][c]);
      newState[3][c] = gfMul(0x0b, state[0][c]) ^ gfMul(0x0d, state[1][c]) ^ gfMul(0x09, state[2][c]) ^ gfMul(0x0e, state[3][c]);
    }
    return newState;
  }

  // Key Expansion
  static List<List<int>> keyExpansion(List<int> key) {
    int nk = key.length ~/ 4;
    int nr = nk + 6;
    int totalWords = 4 * (nr + 1);

    List<List<int>> w = List.generate(totalWords, (_) => List.filled(4, 0));

    for (int i = 0; i < nk; i++) {
      w[i] = key.sublist(i * 4, (i + 1) * 4);
    }

    for (int i = nk; i < totalWords; i++) {
      List<int> temp = List.from(w[i - 1]);

      if (i % nk == 0) {
        temp = [temp[1], temp[2], temp[3], temp[0]];
        temp = temp.map((b) => SBOX[b]).toList();
        temp[0] ^= RCON[(i ~/ nk) - 1];
      } else if (nk > 6 && i % nk == 4) {
        temp = temp.map((b) => SBOX[b]).toList();
      }

      w[i] = List.generate(4, (j) => w[i - nk][j] ^ temp[j]);
    }

    return w;
  }

  // AddRoundKey
  static List<List<int>> addRoundKey(List<List<int>> state, List<List<int>> roundKey) {
    List<List<int>> newState = List.generate(4, (_) => List.filled(4, 0));
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        newState[r][c] = state[r][c] ^ roundKey[r][c];
      }
    }
    return newState;
  }

  // AES Encryption
  static List<int> encryptBlock(List<int> block, List<int> key) {
    int nr = (key.length ~/ 4) + 6;
    List<List<int>> expandedKey = keyExpansion(key);

    List<List<int>> state = List.generate(4, (r) => List.generate(4, (c) => block[r + 4 * c]));

    List<List<int>> roundKey = List.generate(4, (r) => List.generate(4, (c) => expandedKey[c][r]));
    state = addRoundKey(state, roundKey);

    for (int round = 1; round < nr; round++) {
      state = subBytes(state);
      state = shiftRows(state);
      state = mixColumns(state);
      roundKey = List.generate(4, (r) => List.generate(4, (c) => expandedKey[round * 4 + c][r]));
      state = addRoundKey(state, roundKey);
    }

    state = subBytes(state);
    state = shiftRows(state);
    roundKey = List.generate(4, (r) => List.generate(4, (c) => expandedKey[nr * 4 + c][r]));
    state = addRoundKey(state, roundKey);

    List<int> output = [];
    for (int c = 0; c < 4; c++) {
      for (int r = 0; r < 4; r++) {
        output.add(state[r][c]);
      }
    }

    return output;
  }

  // AES Decryption
  static List<int> decryptBlock(List<int> block, List<int> key) {
    int nr = (key.length ~/ 4) + 6;
    List<List<int>> expandedKey = keyExpansion(key);

    List<List<int>> state = List.generate(4, (r) => List.generate(4, (c) => block[r + 4 * c]));

    List<List<int>> roundKey = List.generate(4, (r) => List.generate(4, (c) => expandedKey[nr * 4 + c][r]));
    state = addRoundKey(state, roundKey);

    for (int round = nr - 1; round > 0; round--) {
      state = invShiftRows(state);
      state = invSubBytes(state);
      roundKey = List.generate(4, (r) => List.generate(4, (c) => expandedKey[round * 4 + c][r]));
      state = addRoundKey(state, roundKey);
      state = invMixColumns(state);
    }

    state = invShiftRows(state);
    state = invSubBytes(state);
    roundKey = List.generate(4, (r) => List.generate(4, (c) => expandedKey[c][r]));
    state = addRoundKey(state, roundKey);

    List<int> output = [];
    for (int c = 0; c < 4; c++) {
      for (int r = 0; r < 4; r++) {
        output.add(state[r][c]);
      }
    }

    return output;
  }

  // PKCS#7 Padding
  static List<int> addPadding(List<int> data) {
    int padding = 16 - (data.length % 16);
    return data + List.filled(padding, padding);
  }

  static List<int> removePadding(List<int> data) {
    if (data.isEmpty) return data;
    int padding = data.last;
    if (padding < 1 || padding > 16) return data;
    if (data.length < padding) return data; // Lỗi
    for (int i = data.length - padding; i < data.length; i++) {
      if (data[i] != padding) return data; // Lỗi
    }
    return data.sublist(0, data.length - padding);
  }

  // ECB Mode
  static List<int> encryptECB(List<int> plaintext, List<int> key) {
    List<int> padded = addPadding(plaintext);
    List<int> ciphertext = [];

    for (int i = 0; i < padded.length; i += 16) {
      List<int> block = padded.sublist(i, i + 16);
      List<int> encrypted = encryptBlock(block, key);
      ciphertext.addAll(encrypted);
    }

    return ciphertext;
  }

  static List<int> decryptECB(List<int> ciphertext, List<int> key) {
    List<int> plaintext = [];

    for (int i = 0; i < ciphertext.length; i += 16) {
      List<int> block = ciphertext.sublist(i, i + 16);
      List<int> decrypted = decryptBlock(block, key);
      plaintext.addAll(decrypted);
    }

    return removePadding(plaintext);
  }

  // CBC Mode
  static List<int> encryptCBC(List<int> plaintext, List<int> key, List<int> iv) {
    List<int> padded = addPadding(plaintext);
    List<int> ciphertext = [];
    List<int> prevBlock = iv;

    for (int i = 0; i < padded.length; i += 16) {
      List<int> block = padded.sublist(i, i + 16);
      List<int> xored = List.generate(16, (j) => block[j] ^ prevBlock[j]);
      List<int> encrypted = encryptBlock(xored, key);
      ciphertext.addAll(encrypted);
      prevBlock = encrypted;
    }

    return ciphertext;
  }

  static List<int> decryptCBC(List<int> ciphertext, List<int> key, List<int> iv) {
    List<int> plaintext = [];
    List<int> prevBlock = iv;

    for (int i = 0; i < ciphertext.length; i += 16) {
      List<int> block = ciphertext.sublist(i, i + 16);
      List<int> decrypted = decryptBlock(block, key);
      List<int> xored = List.generate(16, (j) => decrypted[j] ^ prevBlock[j]);
      plaintext.addAll(xored);
      prevBlock = block;
    }

    return removePadding(plaintext);
  }
}

// ==================== PLAYFAIR CIPHER ====================
class PlayfairPage extends StatefulWidget {
  const PlayfairPage({super.key});

  @override
  State<PlayfairPage> createState() => _PlayfairPageState();
}

class _PlayfairPageState extends State<PlayfairPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _output = '';
  String _mode = 'encrypt';
  String _matrixSize = '5x5';
  List<List<String>>? _currentMatrix;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Playfair Cipher',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Classic digraph substitution cipher using 5×5 matrix',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'encrypt', label: Text('Encrypt')),
              ButtonSegment(value: 'decrypt', label: Text('Decrypt')),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _mode = newSelection.first;
                _output = '';
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _matrixSize,
            decoration: const InputDecoration(
              labelText: 'Matrix Size',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: '5x5', child: Text('5×5 (25 chars, J→I)')),
              DropdownMenuItem(value: '6x6', child: Text('6×6 (36 chars, A-Z + 0-9)')),
            ],
            onChanged: (value) {
              setState(() {
                _matrixSize = value!;
                _currentMatrix = null;
                _output = '';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Input Text',
              border: OutlineInputBorder(),
              hintText: 'Enter text (letters only)',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyController,
            decoration: const InputDecoration(
              labelText: 'Keyword',
              border: OutlineInputBorder(),
              hintText: 'e.g., PLAYFAIR',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _processPlayfair,
            icon: const Icon(Icons.play_arrow),
            label: Text(_mode == 'encrypt' ? 'Encrypt' : 'Decrypt'),
          ),
          const SizedBox(height: 16),
          if (_currentMatrix != null)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Playfair Matrix:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: _buildMatrixDisplay(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (_output.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Output:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _output));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_output),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatrixDisplay() {
    if (_currentMatrix == null) return const SizedBox();
    
    return Table(
      border: TableBorder.all(color: Colors.blue, width: 2),
      defaultColumnWidth: const FixedColumnWidth(40),
      children: _currentMatrix!.map((row) {
        return TableRow(
          children: row.map((cell) {
            return Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                cell,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  void _processPlayfair() {
    String input = _inputController.text;
    String key = _keyController.text;

    if (input.isEmpty || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text and keyword')),
      );
      return;
    }

    bool is6x6 = _matrixSize == '6x6';

    if (_mode == 'encrypt') {
      setState(() {
        var result = PlayfairCipher.encrypt(input, key, is6x6);
        _output = result['output']!;
        _currentMatrix = result['matrix'] as List<List<String>>;
      });
    } else {
      setState(() {
        var result = PlayfairCipher.decrypt(input, key, is6x6);
        _output = result['output']!;
        _currentMatrix = result['matrix'] as List<List<String>>;
      });
    }
  }
}

class PlayfairCipher {
  static const String SmallAlphabet = "ABCDEFGHIKLMNOPQRSTUVWXYZ";
  static const String LargeAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  static Map<String, dynamic> encrypt(String plaintext, String keyword, bool is6x6) {
    List<List<String>> matrix = _generateMatrix(keyword, is6x6);
    String prepared = _prepareText(plaintext, is6x6);
    List<String> digraphs = _createDigraphs(prepared, is6x6);
    
    List<String> encryptedDigraphs = [];
    for (String digraph in digraphs) {
      encryptedDigraphs.add(_encryptDigraph(digraph, matrix));
    }
    
    return {
      'output': encryptedDigraphs.join(' '), // Add spaces between digraphs
      'matrix': matrix,
    };
  }

  static Map<String, dynamic> decrypt(String ciphertext, String keyword, bool is6x6) {
    List<List<String>> matrix = _generateMatrix(keyword, is6x6);
    String pattern = is6x6 ? r'[^A-Z0-9]' : r'[^A-Z]';
    String cleaned = ciphertext.toUpperCase().replaceAll(RegExp(pattern), '');
    
    StringBuffer result = StringBuffer();
    for (int i = 0; i < cleaned.length; i += 2) {
      if (i + 1 < cleaned.length) {
        String digraph = cleaned[i] + cleaned[i + 1];
        result.write(_decryptDigraph(digraph, matrix));
      }
    }
    
    return {
      'output': result.toString().toLowerCase(),
      'matrix': matrix,
    };
  }

  static List<List<String>> _generateMatrix(String keyword, bool is6x6) {
    if (is6x6) {
      return _generateMatrix6x6(keyword);
    }
    
    String key = keyword.toUpperCase().replaceAll('J', 'I').replaceAll(RegExp(r'[^A-Z]'), '');
    Set<String> used = {};
    List<String> matrixChars = [];

    for (String char in key.split('')) {
      if (!used.contains(char)) {
        used.add(char);
        matrixChars.add(char);
      }
    }

    for (int i = 65; i <= 90; i++) {
      String char = String.fromCharCode(i);
      if (char == 'J') continue;
      if (!used.contains(char)) {
        used.add(char);
        matrixChars.add(char);
      }
    }

    List<List<String>> matrix = [];
    for (int i = 0; i < 5; i++) {
      matrix.add(matrixChars.sublist(i * 5, (i + 1) * 5));
    }

    return matrix;
  }

  static List<List<String>> _generateMatrix6x6(String keyword) {
    String key = keyword.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    Set<String> used = {};
    List<String> matrixChars = [];

    // Add keyword chars
    for (String char in key.split('')) {
      if (!used.contains(char)) {
        used.add(char);
        matrixChars.add(char);
      }
    }

    // Add A-Z
    for (int i = 65; i <= 90; i++) {
      String char = String.fromCharCode(i);
      if (!used.contains(char)) {
        used.add(char);
        matrixChars.add(char);
      }
    }

    // Add 0-9
    for (int i = 48; i <= 57; i++) {
      String char = String.fromCharCode(i);
      if (!used.contains(char)) {
        used.add(char);
        matrixChars.add(char);
      }
    }

    List<List<String>> matrix = [];
    for (int i = 0; i < 6; i++) {
      matrix.add(matrixChars.sublist(i * 6, (i + 1) * 6));
    }

    return matrix;
  }

static String _prepareText(String text, bool is6x6) {
    String alphabet = is6x6 ? LargeAlphabet : SmallAlphabet;
    String upper = text.toUpperCase();
    StringBuffer sb = StringBuffer();

    for (int i = 0; i < upper.length; i++) {
      String char = upper[i];
      if (alphabet.contains(char)) {
        sb.write(char);
      } else if (!is6x6 && char == 'J') { 

        sb.write('I');
      }
    }
    return sb.toString();
  }

  static List<String> _createDigraphs(String text, bool is6x6) {
    const String separator = 'X';
    const String separatorReplacement = 'Y';


    List<String> chars = text.split('');


    for (int i = 0; i <= chars.length - 2; i += 2) {
      if (chars[i] == chars[i + 1]) {

        if (chars[i] == separator) {

          chars.insert(i + 1, separatorReplacement);
        } else {

          chars.insert(i + 1, separator);
        }
      }
    }


    if (chars.length % 2 != 0) {
      if (chars.last == separator) {

        chars.add(separatorReplacement);
      } else {

        chars.add(separator);
      }
    }


    List<String> digraphs = [];
    String formattedText = chars.join(''); 
    for (int i = 0; i < formattedText.length; i += 2) {
      digraphs.add(formattedText.substring(i, i + 2));
    }

    return digraphs;
  }

  static String _encryptDigraph(String digraph, List<List<String>> matrix) {
    int size = matrix.length;
    int row1 = -1, col1 = -1, row2 = -1, col2 = -1;

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (matrix[i][j] == digraph[0]) {
          row1 = i;
          col1 = j;
        }
        if (matrix[i][j] == digraph[1]) {
          row2 = i;
          col2 = j;
        }
      }
    }

    if (row1 == row2) {
      return matrix[row1][(col1 + 1) % size] + matrix[row2][(col2 + 1) % size];
    } else if (col1 == col2) {
      return matrix[(row1 + 1) % size][col1] + matrix[(row2 + 1) % size][col2];
    } else {
      return matrix[row1][col2] + matrix[row2][col1];
    }
  }

  static String _decryptDigraph(String digraph, List<List<String>> matrix) {
    int size = matrix.length;
    int row1 = -1, col1 = -1, row2 = -1, col2 = -1;

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (matrix[i][j] == digraph[0]) {
          row1 = i;
          col1 = j;
        }
        if (matrix[i][j] == digraph[1]) {
          row2 = i;
          col2 = j;
        }
      }
    }

    if (row1 == row2) {
      return matrix[row1][(col1 + size - 1) % size] + matrix[row2][(col2 + size - 1) % size];
    } else if (col1 == col2) {
      return matrix[(row1 + size - 1) % size][col1] + matrix[(row2 + size - 1) % size][col2];
    } else {
      return matrix[row1][col2] + matrix[row2][col1];
    }
  }
}

// ==================== RSA CIPHER ====================
class RSAPage extends StatefulWidget {
  const RSAPage({super.key});

  @override
  State<RSAPage> createState() => _RSAPageState();
}

class _RSAPageState extends State<RSAPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _qController = TextEditingController();
  final TextEditingController _eController = TextEditingController();
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _dController = TextEditingController();
  String _output = '';
  String _mode = 'generate';
  String _operation = 'encrypt'; 

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'RSA Encryption',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Asymmetric encryption with public/private key pairs',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'generate', label: Text('Generate Keys')),
              ButtonSegment(value: 'encrypt', label: Text('Encrypt')),
              ButtonSegment(value: 'decrypt', label: Text('Decrypt')),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _mode = newSelection.first;
                _output = '';
              });
            },
          ),
          const SizedBox(height: 16),
          
          if (_mode == 'generate') ...[
            TextField(
              controller: _pController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prime p',
                border: OutlineInputBorder(),
                hintText: 'e.g., 61',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prime q',
                border: OutlineInputBorder(),
                hintText: 'e.g., 53',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _eController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Public exponent e (optional)',
                border: OutlineInputBorder(),
                hintText: 'Leave empty for auto (default: 65537)',
              ),
            ),
          ],

          if (_mode == 'encrypt') ...[
            TextField(
              controller: _inputController,
              maxLines: 5, 
              decoration: const InputDecoration(
                labelText: 'Plaintext',
                border: OutlineInputBorder(),
                hintText: 'e.g., HELLO',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _eController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Public key e',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Modulus n',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          if (_mode == 'decrypt') ...[
            TextField(
              controller: _inputController,
              maxLines: 5, 
              decoration: const InputDecoration(
                labelText: 'Ciphertext (hex)', 
                border: OutlineInputBorder(),
                hintText: 'e.g., 1A2B3C4D...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Private key d',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Modulus n',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _processRSA,
            icon: const Icon(Icons.play_arrow),
            label: Text(_mode == 'generate' ? 'Generate Keys' : (_mode == 'encrypt' ? 'Encrypt' : 'Decrypt')),
          ),
          const SizedBox(height: 16),
          
          if (_output.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Output:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _output));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_output),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _processRSA() {
    try {
      if (_mode == 'generate') {
        BigInt? p = BigInt.tryParse(_pController.text);
        BigInt? q = BigInt.tryParse(_qController.text);

        if (p == null || q == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid primes p and q')),
          );
          return;
        }

        if (!RSACipher.isPrime(p) || !RSACipher.isPrime(q)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('p and q must be prime numbers')),
          );
          return;
        }

        BigInt? e = _eController.text.isEmpty ? null : BigInt.tryParse(_eController.text);
        Map<String, BigInt> keys = RSACipher.generateKeys(p, q, e);

        setState(() {
          _output = '''
Public Key (e, n):
  e = ${keys['e']}
  n = ${keys['n']}

Private Key (d, n):
  d = ${keys['d']}
  n = ${keys['n']}

φ(n) = ${keys['phi']}

Share Public Key (e, n) for encryption
Keep Private Key (d, n) secret for decryption
''';
        });
      } else if (_mode == 'encrypt') {
        String input = _inputController.text;
        BigInt? e = BigInt.tryParse(_eController.text);
        BigInt? n = BigInt.tryParse(_nController.text);

        if (input.isEmpty || e == null || n == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all fields')),
          );
          return;
        }

        String result = RSACipher.encrypt(input, e, n);
        setState(() {
          _output = 'Ciphertext (hex):\n$result'; 
        });
      } else {
        String input = _inputController.text;
        BigInt? d = BigInt.tryParse(_dController.text);
        BigInt? n = BigInt.tryParse(_nController.text);

        if (input.isEmpty || d == null || n == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all fields')),
          );
          return;
        }

        String result = RSACipher.decrypt(input, d, n);
        setState(() {
          _output = 'Plaintext:\n$result'; 
        });
      }
    } catch (e) {

      setState(() {
        _output = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class RSACipher {

  static List<int> hexToBytes(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }
 

 
  static BigInt _bytesToBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[i]) << (8 * i);
    }
    return result;
  }


  static List<int> _bigIntToBytes(BigInt n, int outputSize) {
    List<int> bytes = List.filled(outputSize, 0);
    BigInt temp = n;
    for (int i = 0; i < outputSize; i++) {
      if (temp == BigInt.zero) break;
      bytes[i] = (temp & BigInt.from(0xFF)).toInt();
      temp = temp >> 8;
    }

    if (temp > BigInt.zero) {
      throw Exception("Output blocksize is too small");
    }
    return bytes;
  }
  


  static bool isPrime(BigInt n) {
    if (n < BigInt.two) return false;
    if (n == BigInt.two) return true;
    if (n % BigInt.two == BigInt.zero) return false;
    for (BigInt i = BigInt.from(3); i * i <= n; i += BigInt.two) {
      if (n % i == BigInt.zero) return false;
    }
    return true;
  }

  static BigInt gcd(BigInt a, BigInt b) {
    while (b != BigInt.zero) {
      BigInt temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  static BigInt modInverse(BigInt e, BigInt phi) {
    return e.modInverse(phi);
  }

  static Map<String, BigInt> generateKeys(BigInt p, BigInt q, BigInt? customE) {
    BigInt n = p * q;
    BigInt phi = (p - BigInt.one) * (q - BigInt.one);
    
    BigInt e = customE ?? BigInt.from(65537);
    if (customE == null) {
      e = BigInt.from(3);
      while (e < phi) {
        if (gcd(e, phi) == BigInt.one) break;
        e += BigInt.two;
      }
    }
    
    if (gcd(e, phi) != BigInt.one) {
      e = BigInt.from(3);
      while (gcd(e, phi) != BigInt.one && e < phi) {
        e += BigInt.two;
      }
    }
    
    BigInt d = modInverse(e, phi);
    
    return {
      'e': e,
      'd': d,
      'n': n,
      'phi': phi,
    };
  }


  static String encrypt(String plaintext, BigInt e, BigInt n) {
 
    int inBlockSize = (n.bitLength - 1) ~/ 8;
    int outBlockSize = (n.bitLength + 7) ~/ 8;

    if (inBlockSize == 0) {
      throw Exception("Modulus N is too small for block encryption.");
    }

    List<int> plainBytes = utf8.encode(plaintext);
    List<int> cipherBytes = [];

    for (int i = 0; i < plainBytes.length; i += inBlockSize) {
      int end = (i + inBlockSize > plainBytes.length) ? plainBytes.length : (i + inBlockSize);
      List<int> block = plainBytes.sublist(i, end);
      

      List<int> blockWithPad = List.filled(inBlockSize + 1, 0);
      for(int j=0; j < block.length; j++) {
        blockWithPad[j] = block[j];
      }

      BigInt m = _bytesToBigInt(blockWithPad);

      if (m >= n) {
        throw Exception("Block M >= N. Plaintext block is too large for modulus N.");
      }

      BigInt c = m.modPow(e, n);
      List<int> outBlock = _bigIntToBytes(c, outBlockSize);
      cipherBytes.addAll(outBlock);
    }

    return bytesToHex(cipherBytes);
  }

  static String decrypt(String ciphertextHex, BigInt d, BigInt n) {

    int inBlockSize = (n.bitLength + 7) ~/ 8;
    int outBlockSize = (n.bitLength - 1) ~/ 8;

    if (inBlockSize == 0 || outBlockSize == 0) {
      throw Exception("Modulus N is too small for block decryption.");
    }

    List<int> cipherBytes = hexToBytes(ciphertextHex.replaceAll(RegExp(r'\s'), ''));
    if (cipherBytes.length % inBlockSize != 0) {
      throw Exception("Ciphertext length is not a multiple of the input block size.");
    }

    List<int> plainBytes = [];

    for (int i = 0; i < cipherBytes.length; i += inBlockSize) {
      List<int> block = cipherBytes.sublist(i, i + inBlockSize);
      
      BigInt c = _bytesToBigInt(block);
      BigInt m = c.modPow(d, n);
      List<int> outBlock = _bigIntToBytes(m, outBlockSize);
      plainBytes.addAll(outBlock);
    }

    while (plainBytes.isNotEmpty && plainBytes.last == 0) {
      plainBytes.removeLast();
    }

    return utf8.decode(plainBytes);
  }
}