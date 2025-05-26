import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minesweeperapp/core/theme/app_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int rows = 12;
  int columns = 8;
  int totalMines = 2;
  List<List<Cell>> grid = [];

  @override
  void initState() {
    super.initState();
    _intializeGrid();
  }

  void _intializeGrid() {
    // Initialize grid with empty cells
    grid = List.generate(
      rows,
      (row) => List.generate(columns, (col) => Cell(row: row, col: col)),
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
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "Flag",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text("0", style: Theme.of(context).textTheme.headlineLarge),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        cell.isOpen
                            ? Colors.white
                            : cell.isFlagged
                            ? AppColor.primarySwatch[100]
                            : AppColor.primaryColor,
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
