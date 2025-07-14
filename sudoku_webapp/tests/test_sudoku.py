import pytest
import sys
import os

# プロジェクトのルートディレクトリをPythonパスに追加
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sudoku_solver import SudokuSolver
from sudoku_generator import SudokuGenerator

class TestSudokuSolver:
    def setup_method(self):
        self.solver = SudokuSolver()
    
    def test_solve_easy_puzzle(self):
        # 簡単なテスト用パズル
        puzzle = [
            [5, 3, 0, 0, 7, 0, 0, 0, 0],
            [6, 0, 0, 1, 9, 5, 0, 0, 0],
            [0, 9, 8, 0, 0, 0, 0, 6, 0],
            [8, 0, 0, 0, 6, 0, 0, 0, 3],
            [4, 0, 0, 8, 0, 3, 0, 0, 1],
            [7, 0, 0, 0, 2, 0, 0, 0, 6],
            [0, 6, 0, 0, 0, 0, 2, 8, 0],
            [0, 0, 0, 4, 1, 9, 0, 0, 5],
            [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ]
        
        solution = self.solver.solve(puzzle)
        assert solution is not None
        assert self.solver.is_valid(solution)
    
    def test_invalid_puzzle(self):
        # 無効なパズル（同じ行に重複する数字）
        invalid_puzzle = [
            [1, 1, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0]
        ]
        
        assert not self.solver.is_valid(invalid_puzzle)

class TestSudokuGenerator:
    def setup_method(self):
        self.generator = SudokuGenerator()
    
    def test_generate_puzzle(self):
        puzzle = self.generator.generate('easy')
        
        # パズルが9x9であることを確認
        assert len(puzzle) == 9
        assert all(len(row) == 9 for row in puzzle)
        
        # 空のセルがあることを確認
        empty_cells = sum(row.count(0) for row in puzzle)
        assert empty_cells > 0
        
        # パズルが有効であることを確認
        solver = SudokuSolver()
        assert solver.is_valid(puzzle)

if __name__ == '__main__':
    pytest.main([__file__])
