import numpy as np
from typing import List, Optional, Tuple

class SudokuSolver:
    """数独パズルのソルバークラス"""
    
    def __init__(self):
        self.size = 9
        self.box_size = 3
    
    def solve(self, puzzle: List[List[int]]) -> Optional[List[List[int]]]:
        """
        数独パズルを解く
        
        Args:
            puzzle: 9x9の数独パズル（0は空のセル）
            
        Returns:
            解けた場合は解答、解けない場合はNone
        """
        if not self.is_valid(puzzle):
            return None
            
        # パズルをコピーして解く
        solution = [row[:] for row in puzzle]
        
        if self._solve_recursive(solution):
            return solution
        return None
    
    def _solve_recursive(self, puzzle: List[List[int]]) -> bool:
        """
        再帰的にパズルを解く
        
        Args:
            puzzle: 現在の状態のパズル
            
        Returns:
            解けた場合True、解けない場合False
        """
        empty_cell = self._find_empty_cell(puzzle)
        if not empty_cell:
            return True  # すべてのセルが埋まった
        
        row, col = empty_cell
        
        for num in range(1, 10):
            if self._is_safe(puzzle, row, col, num):
                puzzle[row][col] = num
                
                if self._solve_recursive(puzzle):
                    return True
                
                # バックトラック
                puzzle[row][col] = 0
        
        return False
    
    def _find_empty_cell(self, puzzle: List[List[int]]) -> Optional[Tuple[int, int]]:
        """
        空のセルを見つける
        
        Args:
            puzzle: パズル
            
        Returns:
            空のセルの座標、見つからない場合はNone
        """
        for i in range(self.size):
            for j in range(self.size):
                if puzzle[i][j] == 0:
                    return (i, j)
        return None
    
    def _is_safe(self, puzzle: List[List[int]], row: int, col: int, num: int) -> bool:
        """
        指定した位置に数字を置けるかチェック
        
        Args:
            puzzle: パズル
            row: 行
            col: 列
            num: 置く数字
            
        Returns:
            置ける場合True、置けない場合False
        """
        # 行をチェック
        for j in range(self.size):
            if puzzle[row][j] == num:
                return False
        
        # 列をチェック
        for i in range(self.size):
            if puzzle[i][col] == num:
                return False
        
        # 3x3ボックスをチェック
        start_row = row - row % self.box_size
        start_col = col - col % self.box_size
        
        for i in range(self.box_size):
            for j in range(self.box_size):
                if puzzle[start_row + i][start_col + j] == num:
                    return False
        
        return True
    
    def is_valid(self, puzzle: List[List[int]]) -> bool:
        """
        パズルが有効かチェック
        
        Args:
            puzzle: チェックするパズル
            
        Returns:
            有効な場合True、無効な場合False
        """
        if len(puzzle) != self.size or any(len(row) != self.size for row in puzzle):
            return False
        
        for i in range(self.size):
            for j in range(self.size):
                if puzzle[i][j] != 0:
                    # 一時的に値を保存
                    temp = puzzle[i][j]
                    puzzle[i][j] = 0
                    
                    # その位置に置けるかチェック
                    if not self._is_safe(puzzle, i, j, temp):
                        puzzle[i][j] = temp
                        return False
                    
                    # 値を戻す
                    puzzle[i][j] = temp
        
        return True
