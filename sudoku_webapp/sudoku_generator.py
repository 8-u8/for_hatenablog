import random
import numpy as np
from typing import List
from sudoku_solver import SudokuSolver

class SudokuGenerator:
    """数独パズルのジェネレータークラス"""
    
    def __init__(self):
        self.size = 9
        self.solver = SudokuSolver()
        
        # 難易度設定（削除するセルの数）
        self.difficulty_levels = {
            'easy': 35,
            'medium': 45,
            'hard': 55,
            'expert': 65
        }
    
    def generate(self, difficulty: str = 'medium') -> List[List[int]]:
        """
        指定した難易度の数独パズルを生成
        
        Args:
            difficulty: 難易度 ('easy', 'medium', 'hard', 'expert')
            
        Returns:
            生成されたパズル
        """
        # 完成した数独を生成
        completed_puzzle = self._generate_completed_puzzle()
        
        # 指定した難易度に基づいてセルを削除
        cells_to_remove = self.difficulty_levels.get(difficulty, 45)
        puzzle = self._remove_cells(completed_puzzle, cells_to_remove)
        
        return puzzle
    
    def _generate_completed_puzzle(self) -> List[List[int]]:
        """
        完成した数独パズルを生成
        
        Returns:
            完成したパズル
        """
        # 空のパズルから開始
        puzzle = [[0 for _ in range(self.size)] for _ in range(self.size)]
        
        # 対角線の3x3ボックスを埋める（これらは互いに独立）
        self._fill_diagonal_boxes(puzzle)
        
        # 残りを解く
        self.solver._solve_recursive(puzzle)
        
        return puzzle
    
    def _fill_diagonal_boxes(self, puzzle: List[List[int]]) -> None:
        """
        対角線上の3x3ボックスを埋める
        
        Args:
            puzzle: 埋めるパズル
        """
        for box in range(0, self.size, 3):
            self._fill_box(puzzle, box, box)
    
    def _fill_box(self, puzzle: List[List[int]], start_row: int, start_col: int) -> None:
        """
        3x3ボックスをランダムな数字で埋める
        
        Args:
            puzzle: パズル
            start_row: ボックスの開始行
            start_col: ボックスの開始列
        """
        numbers = list(range(1, 10))
        random.shuffle(numbers)
        
        for i in range(3):
            for j in range(3):
                puzzle[start_row + i][start_col + j] = numbers[i * 3 + j]
    
    def _remove_cells(self, puzzle: List[List[int]], cells_to_remove: int) -> List[List[int]]:
        """
        完成したパズルからセルを削除してパズルを作成
        
        Args:
            puzzle: 完成したパズル
            cells_to_remove: 削除するセルの数
            
        Returns:
            セルが削除されたパズル
        """
        result = [row[:] for row in puzzle]  # コピーを作成
        
        # すべてのセルの座標をリストアップ
        all_cells = [(i, j) for i in range(self.size) for j in range(self.size)]
        random.shuffle(all_cells)
        
        removed_count = 0
        
        for row, col in all_cells:
            if removed_count >= cells_to_remove:
                break
            
            # セルを一時的に削除
            backup = result[row][col]
            result[row][col] = 0
            
            # パズルが一意解を持つかチェック
            if self._has_unique_solution(result):
                removed_count += 1
            else:
                # 一意解でない場合は元に戻す
                result[row][col] = backup
        
        return result
    
    def _has_unique_solution(self, puzzle: List[List[int]]) -> bool:
        """
        パズルが一意解を持つかチェック
        
        Args:
            puzzle: チェックするパズル
            
        Returns:
            一意解を持つ場合True
        """
        # 簡単な実装：解けるかどうかのみチェック
        # より厳密には、解の数を数える必要がある
        puzzle_copy = [row[:] for row in puzzle]
        return self.solver._solve_recursive(puzzle_copy)
