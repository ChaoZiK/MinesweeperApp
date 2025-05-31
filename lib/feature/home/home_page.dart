import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minesweeperapp/core/theme/app_color.dart';

class HomePage extends StatefulWidget {
  final String difficulty;
  const HomePage({super.key, required this.difficulty});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int rows = 12;
  int columns = 8;
  int totalMines = 10;
  List<List<Cell>> grid = [];

  int flagCount = 10;
  bool gameOver = false;

  final List<GameState> undoStack = [];
  final int maxUndoSteps = 10;

  @override
  void initState() {
    super.initState();
    _setDifficulty();
    _intializeGrid();
  }

  void _setDifficulty() {
    switch (widget.difficulty) {
      case 'easy':
        rows = 8;
        columns = 8;
        totalMines = 10;
        flagCount = 10;
        break;
      case 'medium':
        rows = 12;
        columns = 8;
        totalMines = 20;
        flagCount = 20;
        break;
      case 'hard':
        rows = 16;
        columns = 10;
        totalMines = 30;
        flagCount = 30;
        break;
      default:
        rows = 8;
        columns = 8;
        totalMines = 10;
        flagCount = 10;
    }
  }

  void _intializeGrid() {
    // Initialize grid with empty cells
    grid = List.generate(
      rows,
      (row) => List.generate(columns, (col) => Cell(row: row, col: col)),
    );

    // Add mines to random cells
    final random = Random();
    int count = 0;
    while (count < totalMines) {
      int randomRow = random.nextInt(rows);
      int randomCol = random.nextInt(columns);
      if (!grid[randomRow][randomCol].hasMine) {
        grid[randomRow][randomCol].hasMine = true;
        count++;
      }
    }

    // Calculate adjacent mines for each cell
    // a number 0-8 base on surounding / neighbour mines
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        /// has mines no nothing
        if (grid[row][col].hasMine) continue;

        int adjacentMines = 0;
        for (final dir in directions) {
          int newRow = row + dir.dy.toInt();
          int newCol = col + dir.dx.toInt();

          if (_isValidCell(newRow, newCol) && grid[newRow][newCol].hasMine) {
            adjacentMines++;
          }
        }

        /// adjacentMines indicate the number of mines
        /// in its sourounding / neighbour
        grid[row][col].adjacentMines = adjacentMines;
      }
    }
  }

  /// [-1,-1] [-1,0] [-1,1]
  ///
  /// [0,-1] [cell] [0,1]
  ///
  /// [1,-1] [1,0] [1,1]
  final directions = [
    const Offset(-1, -1),
    const Offset(-1, 0),
    const Offset(-1, 1),
    const Offset(0, -1),
    const Offset(0, 1),
    const Offset(1, -1),
    const Offset(1, 0),
    const Offset(1, 1),
  ];

  // check for valid cell
  bool _isValidCell(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < columns;
  }

  List<List<Cell>> copyGrid(List<List<Cell>> original) {
    return original
        .map(
          (row) =>
              row
                  .map(
                    (cell) => Cell(
                      row: cell.row,
                      col: cell.col,
                      isOpen: cell.isOpen,
                      hasMine: cell.hasMine,
                      isFlagged: cell.isFlagged,
                      adjacentMines: cell.adjacentMines,
                    ),
                  )
                  .toList(),
        )
        .toList();
  }

  void _handleCellTap(Cell cell) {
    if (gameOver || cell.isOpen || cell.isFlagged) return;

    // add gameState to stack
    undoStack.add(
      GameState(grid: copyGrid(grid), flagCount: flagCount, gameOver: gameOver),
    );
    if (undoStack.length > maxUndoSteps) undoStack.removeAt(0);

    setState(() {
      cell.isOpen = true;

      if (cell.hasMine) {
        // Game over - show all mines
        gameOver = true;
        for (final row in grid) {
          for (final cell in row) {
            if (cell.hasMine) {
              cell.isOpen = true;
            }
          }
        }
        showSnackBar(context, message: "Game Over!!!");
      } else if (_checkForWin()) {
        // Game won - show all cells
        gameOver = true;

        for (final row in grid) {
          for (final cell in row) {
            cell.isOpen = true;
          }
        }
        showSnackBar(context, message: "Congratulation :D");
      } else if (cell.adjacentMines == 0) {
        // Open adjacent cells if there are no mines nearby
        _openAdjacentCells(cell.row, cell.col);
      }
    });
  }

  bool _checkForWin() {
    for (final row in grid) {
      for (final cell in row) {
        // chek if we still has un open cell
        // that are not mines
        // if we has on immidiate return
        // indicate that the game still not over
        if (!cell.hasMine && !cell.isOpen) {
          return false;
        }
      }
    }

    return true;
  }

  /// open neibour cell untill found a mines
  void _openAdjacentCells(int row, int col) {
    /// open neigbour cells
    for (final dir in directions) {
      int newRow = row + dir.dy.toInt();
      int newCol = col + dir.dx.toInt();

      /// if not open and not mines
      if (_isValidCell(newRow, newCol) &&
          !grid[newRow][newCol].hasMine &&
          !grid[newRow][newCol].isOpen) {
        setState(() {
          // open the cell
          grid[newRow][newCol].isOpen = true;
          // and check if its has no mines in suroinding
          /// open adjacentCells in that position

          /// this process will get loop untul it find a mines
          if (grid[newRow][newCol].adjacentMines == 0) {
            _openAdjacentCells(newRow, newCol);
          }
        });
      }
    }
    if (gameOver) return;

    if (_checkForWin()) {
      gameOver = true;
      for (final row in grid) {
        for (final cell in row) {
          if (cell.hasMine) {
            cell.isOpen = true;
          }
        }
      }
      showSnackBar(context, message: "Congratulation :D");
    }
  }

  void _handleCellLongPress(Cell cell) {
    if (cell.isOpen) return;
    if (flagCount <= 0 && !cell.isFlagged) return;

    setState(() {
      cell.isFlagged = !cell.isFlagged;

      if (cell.isFlagged) {
        flagCount--;
      } else {
        flagCount++;
      }
    });
  }

  void _undo() {
    if (undoStack.isEmpty) {
      showSnackBar(context, message: "Nothing to undo");
      return;
    }

    final last = undoStack.removeLast();
    setState(() {
      grid = copyGrid(last.grid);
      flagCount = last.flagCount;
      gameOver = last.gameOver;
    });
  }

  void _reset() {
    setState(() {
      grid = [];
      gameOver = false;
      flagCount = totalMines;
      undoStack.clear();
    });

    _intializeGrid();
  }

  void showSnackBar(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Minesweeper',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Put 2 buttons in 1 Wrap
                Wrap(
                  spacing: 8,
                  children: [
                    // UNDO
                    ElevatedButton.icon(
                      onPressed: _undo,
                      icon: const Icon(
                        Icons.undo,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Undo",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    // RESET
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(
                        Icons.restart_alt,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),

                // Swapped positions of Flag count and buttons
                Column(
                  children: [
                    Text(
                      "Flag",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      flagCount.toString(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.all(24),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: rows * columns,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final int row = index ~/ columns;
              final int col = index % columns;
              final cell = grid[row][col];

              return GestureDetector(
                onTap: () => _handleCellTap(cell),
                onLongPress: () => _handleCellLongPress(cell),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        cell.isOpen
                            ? Colors.white
                            : cell.isFlagged
                            ? AppColor.primarySwatch[100]
                            : Colors.pink,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        offset: const Offset(-4, -4),
                        color: AppColor.white,
                      ),
                      BoxShadow(
                        blurRadius: 4,
                        offset: const Offset(4, 4),
                        color: AppColor.lightGray,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cell.isOpen
                          ? cell.hasMine
                              ? '💣'
                              : '${cell.adjacentMines}'
                          : cell.isFlagged
                          ? '🚩'
                          : '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: cell.isFlagged ? 24 : 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Cell {
  final int row;
  final int col;

  bool hasMine;
  bool isOpen;
  bool isFlagged;

  /// the sum of surounded mines
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.isFlagged = false,
    this.hasMine = false,
    this.isOpen = false,
    this.adjacentMines = 0,
  });
}

class GameState {
  final List<List<Cell>> grid;
  final int flagCount;
  final bool gameOver;

  GameState({
    required this.grid,
    required this.flagCount,
    required this.gameOver,
  });
}
