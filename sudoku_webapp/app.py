from flask import Flask, render_template, request, jsonify
import json
from sudoku_solver import SudokuSolver
from sudoku_generator import SudokuGenerator

app = Flask(__name__)

@app.route('/')
def index():
    """メインページを表示"""
    return render_template('index.html')

@app.route('/generate', methods=['POST'])
def generate_puzzle():
    """新しい数独パズルを生成"""
    difficulty = request.json.get('difficulty', 'medium')
    generator = SudokuGenerator()
    puzzle = generator.generate(difficulty)
    return jsonify({'puzzle': puzzle})

@app.route('/solve', methods=['POST'])
def solve_puzzle():
    """数独パズルを解く"""
    puzzle = request.json.get('puzzle')
    if not puzzle:
        return jsonify({'error': 'パズルが提供されていません'}), 400
    
    solver = SudokuSolver()
    solution = solver.solve(puzzle)
    
    if solution:
        return jsonify({'solution': solution, 'solvable': True})
    else:
        return jsonify({'solvable': False, 'message': '解けないパズルです'})

@app.route('/validate', methods=['POST'])
def validate_puzzle():
    """数独パズルの有効性をチェック"""
    puzzle = request.json.get('puzzle')
    solver = SudokuSolver()
    is_valid = solver.is_valid(puzzle)
    return jsonify({'valid': is_valid})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
