import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';


void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GetStorage storage = GetStorage();
  late List<List<int>> grid = (storage.read('grid') as List<dynamic>?)
      ?.map((e) => (e as List<dynamic>).cast<int>())
      .toList() ?? List.generate(4, (_) => List.generate(4, (_) => 0));

  final Map<int, Color> _tileColor =  {
    2: Colors.purple.shade50,
    4: Colors.purple.shade100,
    8: Colors.purple.shade300,
    16: Colors.purple.shade400,
    32: Colors.purple.shade500,
    64: Colors.purple.shade600,
    128: Colors.yellow.shade200,
    256: Colors.yellow.shade300,
    512: Colors.yellow.shade400,
    1024: Colors.yellow.shade500,
    2048: Colors.yellow.shade600
  };
  final Random _random = Random();
  late int _score = storage.read('score') ?? 0;
  late int _highScore = storage.read('highScore') ?? 0; //TODO : Add highscore persistance
  late int _highestTile = storage.read('highestTile') ?? 0;
  late bool _stillPlaying = storage.read('stillPlaying') ?? false;

  @override
  void initState() {
    super.initState();
    if (!storage.hasData('grid')) {
      _addRandomTwo(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48), // Placeholder for centering
              const Text(
                '2048',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetGame,
              ),
            ],
          ),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'SCORE: $_highestTile',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'BEST: $_highestTile',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  setState(() {
                    _swipeRight();
                    _addRandomTwo();
                    storage.write('grid', grid);
                  });
                } else if (details.primaryVelocity! < 0) {
                  setState(() {
                    _swipeLeft();
                    _addRandomTwo();
                    storage.write('grid', grid);
                  });
                }
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  setState(() {
                    _swipeDown();
                    _addRandomTwo();
                    storage.write('grid', grid);
                  });
                } else if (details.primaryVelocity! < 0) {
                  setState(() {
                    _swipeUp();
                    _addRandomTwo();
                    storage.write('grid', grid);
                  });
                }
              },
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.9,
                height: MediaQuery.sizeOf(context).width * 0.9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                controller: ScrollController(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  int row = index ~/ 4;
                  int col = index % 4;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: numberTile(grid[row][col]),
                    ),
                  );
                },
              ),
            ),
          )
          ),])
    ));
  }

  Widget numberTile(int number) {
    return Container(
      decoration: BoxDecoration(
        color: number == 0 ? Colors.grey[200] : _tileColor.containsKey(number) ? _tileColor[number] : Colors.yellow.shade600,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          number == 0 ? '' : number.toString(),
          style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      if (_score > _highScore) {
        _highScore = _score;
        storage.write('highScore', _highScore);
      }
      grid = List.generate(4, (_) => List.generate(4, (_) => 0));
      _addRandomTwo(2);
      _score = 0;
      _stillPlaying = false;
      storage.write('highScore', _highScore);
      storage.write('score', _score);
      storage.write('stillPlaying', _stillPlaying);
    });
  }

  void _addRandomTwo([int? amount]) {
    amount ??= 1;
    for (int i = 0; i < amount; i++) {
      List<int> emptySquares = [];
      for (int i = 0; i < 16; i++) {
        int row = i ~/ 4;
        int col = i % 4;
        if (grid[row][col] == 0) {
          emptySquares.add(i);
        }
      }

      if (emptySquares.isNotEmpty) {
        int randomIndex = emptySquares[_random.nextInt(emptySquares.length)];
        int row = randomIndex ~/ 4;
        int col = randomIndex % 4;
        grid[row][col] = 2;
      }
    }
  }

  void addScore(int number) {
    setState(() {
      _score += number;
      if (number > _highestTile) {
        _highestTile = number;
        storage.write('highestTile', _highestTile);
      }
      if (_highestTile >= 2048 && !_stillPlaying) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('You Win!'),
              content: const Text('Congratulations! You reached 2048!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetGame();
                  },
                  child: const Text('Try again'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _stillPlaying = true;
                    storage.write('stillPlaying', _stillPlaying);
                  },
                  child: const Text('Keep going'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _swipeRight() {
    if (kDebugMode) {print('Swipe Right');}
      for (int i = 0; i < 4; i++) {
        List<int> newRow = List.filled(4, 0);
        int index = 3;
        for (int j = 3; j >= 0; j--) {
          if (grid[i][j] != 0) {
            newRow[index] = grid[i][j];
            index--;
          }
        }
        for (int j = 3; j > 0; j--) {
          if (newRow[j] == newRow[j - 1] && newRow[j] != 0) {
            newRow[j] *= 2;
            newRow[j - 1] = 0;
            addScore(newRow[j]);
          }
        }
        index = 3;
        for (int j = 3; j >= 0; j--) {
          if (newRow[j] != 0) {
            grid[i][index] = newRow[j];
            index--;
          }
        }
        for (int j = index; j >= 0; j--) {
          grid[i][j] = 0;
        }
      }
  }

  void _swipeLeft() {
    if (kDebugMode) {print('Swipe Left');}
      for (int i = 0; i < 4; i++) {
        List<int> newRow = List.filled(4, 0);
        int index = 0;
        for (int j = 0; j < 4; j++) {
          if (grid[i][j] != 0) {
            newRow[index] = grid[i][j];
            index++;
          }
        }
        for (int j = 0; j < 3; j++) {
          if (newRow[j] == newRow[j + 1] && newRow[j] != 0) {
            newRow[j] *= 2;
            newRow[j + 1] = 0;
            addScore(newRow[j]);
          }
        }
        index = 0;
        for (int j = 0; j < 4; j++) {
          if (newRow[j] != 0) {
            grid[i][index] = newRow[j];
            index++;
          }
        }
        for (int j = index; j < 4; j++) {
          grid[i][j] = 0;
        }
      }
  }

  void _swipeUp() {
    if (kDebugMode) {print('Swipe Up');}
      for (int j = 0; j < 4; j++) {
        List<int> newCol = List.filled(4, 0);
        int index = 0;
        for (int i = 0; i < 4; i++) {
          if (grid[i][j] != 0) {
            newCol[index] = grid[i][j];
            index++;
          }
        }
        for (int i = 0; i < 3; i++) {
          if (newCol[i] == newCol[i + 1] && newCol[i] != 0) {
            newCol[i] *= 2;
            newCol[i + 1] = 0;
            addScore(newCol[i]);
          }
        }
        index = 0;
        for (int i = 0; i < 4; i++) {
          if (newCol[i] != 0) {
            grid[i][j] = newCol[i];
            index++;
          }
        }
        for (int i = index; i < 4; i++) {
          grid[i][j] = 0;
        }
      }
  }

  void _swipeDown() {
    if (kDebugMode) {print('Swipe Down');}
      for (int j = 0; j < 4; j++) {
        List<int> newCol = List.filled(4, 0);
        int index = 3;
        for (int i = 3; i >= 0; i--) {
          if (grid[i][j] != 0) {
            newCol[index] = grid[i][j];
            index--;
          }
        }
        for (int i = 3; i > 0; i--) {
          if (newCol[i] == newCol[i - 1] && newCol[i] != 0) {
            newCol[i] *= 2;
            newCol[i - 1] = 0;
            addScore(newCol[i]);
          }
        }
        index = 3;
        for (int i = 3; i >= 0; i--) {
          if (newCol[i] != 0) {
            grid[i][j] = newCol[i];
            index--;
          }
        }
        for (int i = index; i >= 0; i--) {
          grid[i][j] = 0;
        }
      }
  }
}

