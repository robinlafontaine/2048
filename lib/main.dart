import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'GameProvider.dart';

void main() async {
  await GetStorage.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MyApp(),
    ),
  );
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

class GamePage extends StatelessWidget {
  const GamePage({super.key});

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
                onPressed: () {
                  context.read<GameProvider>().resetGame();
                },
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
                          Consumer<GameProvider>(
                            builder: (context, game, child) {
                              return Container(
                                margin: const EdgeInsets.only(left: 8.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  'SCORE: ${game.score}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          Consumer<GameProvider>(
                            builder: (context, game, child) {
                              return Container(
                                margin: const EdgeInsets.only(left: 8.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  'BEST: ${game.highScore}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          context.read<GameProvider>().swipeRight();
                        } else if (details.primaryVelocity! < 0) {
                          context.read<GameProvider>().swipeLeft();
                        }
                        if (context.read<GameProvider>().isGameOver()) {
                          _showGameOverDialog(context);
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          context.read<GameProvider>().swipeDown();
                        } else if (details.primaryVelocity! < 0) {
                          context.read<GameProvider>().swipeUp();
                        }
                        if (context.read<GameProvider>().isGameOver()) {
                          _showGameOverDialog(context);
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
                          child: Consumer<GameProvider>(
                            builder: (context, game, child) {
                              return GridView.builder(
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
                                      child: numberTile(game.grid[row][col], game.tileColor),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      )
                  ),
                ])
        ));
  }

  Widget numberTile(int number, Map<int, Color> tileColor) {
    return Container(
      decoration: BoxDecoration(
        color: number == 0 ? Colors.grey[200] : tileColor.containsKey(number)
            ? tileColor[number]
            : Colors.yellow.shade600,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          number == 0 ? '' : number.toString(),
          style: const TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: const Text('You lost!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<GameProvider>().resetGame();
              },
              child: const Text('Try again'),
            ),
          ],
        );
      },
    );
  }
}