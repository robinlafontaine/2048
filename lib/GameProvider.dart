import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class GameProvider extends ChangeNotifier {
  final GetStorage storage = GetStorage();
  late List<List<int>> grid;
  final Map<int, Color> _tileColor = {
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
  late int _score;
  late int _highScore;
  late int _highestTile;
  late bool _stillPlaying;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    grid = (storage.read('grid') as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).cast<int>())
        .toList() ?? List.generate(4, (_) => List.generate(4, (_) => 0));
    _score = storage.read('score') ?? 0;
    _highScore = storage.read('highScore') ?? 0;
    _highestTile = storage.read('highestTile') ?? 0;
    _stillPlaying = storage.read('stillPlaying') ?? false;
    if (!storage.hasData('grid')) {
      _addRandomTwo(2);
    }
  }

  Map<int, Color> get tileColor => _tileColor;

  int get score => _score;

  int get highScore => _highScore;

  int get highestTile => _highestTile;

  bool get stillPlaying => _stillPlaying;

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
    notifyListeners();
  }

  void addScore(int number) {
    _score += number;
    if (number > _highestTile) {
      _highestTile = number;
      storage.write('highestTile', _highestTile);
    }
    if (_highestTile >= 2048 && !_stillPlaying) {
      _stillPlaying = true;
      storage.write('stillPlaying', _stillPlaying);
    }
    notifyListeners();
  }

  void resetGame() {
    if (_score > _highScore) {
      _highScore = _score;
      storage.write('highScore', _highScore);
    }
    grid = List.generate(4, (_) => List.generate(4, (_) => 0));
    _addRandomTwo(2);
    _score = 0;
    _stillPlaying = false;
    storage.write('grid', grid);
    storage.write('highScore', _highScore);
    storage.write('score', _score);
    storage.write('stillPlaying', _stillPlaying);
    notifyListeners();
  }

  bool isGameOver() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) return false;
        if (i < 3 && grid[i][j] == grid[i + 1][j]) return false;
        if (j < 3 && grid[i][j] == grid[i][j + 1]) return false;
      }
    }
    return true;
  }

  bool _gridsAreEqual(List<List<int>> grid1, List<List<int>> grid2) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid1[i][j] != grid2[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void swipeRight() {
    List<List<int>> oldGrid = List.from(grid.map((row) => List<int>.from(row)));
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
    if (!_gridsAreEqual(oldGrid, grid)) {
      _addRandomTwo();
      storage.write('grid', grid);
    }
    notifyListeners();
  }

  void swipeLeft() {
    List<List<int>> oldGrid = List.from(grid.map((row) => List<int>.from(row)));
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
    if (!_gridsAreEqual(oldGrid, grid)) {
      _addRandomTwo();
      storage.write('grid', grid);
    }
    notifyListeners();
  }

  void swipeUp() {
    List<List<int>> oldGrid = List.from(grid.map((row) => List<int>.from(row)));
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
    if (!_gridsAreEqual(oldGrid, grid)) {
      _addRandomTwo();
      storage.write('grid', grid);
    }
    notifyListeners();
  }

  void swipeDown() {
    List<List<int>> oldGrid = List.from(grid.map((row) => List<int>.from(row)));
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
    if (!_gridsAreEqual(oldGrid, grid)) {
      _addRandomTwo();
      storage.write('grid', grid);
    }
    notifyListeners();
  }
}