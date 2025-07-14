class SudokuGame {
    constructor() {
        this.grid = [];
        this.originalPuzzle = [];
        this.currentPuzzle = [];
        this.selectedCell = null;

        this.initializeGrid();
        this.bindEvents();
    }

    initializeGrid() {
        const gridElement = document.getElementById('sudoku-grid');
        gridElement.innerHTML = '';

        for (let i = 0; i < 81; i++) {
            const cell = document.createElement('input');
            cell.type = 'text';
            cell.className = 'cell';
            cell.maxLength = 1;
            cell.dataset.index = i;

            // 数字のみ入力可能にする
            cell.addEventListener('input', (e) => {
                const value = e.target.value;
                if (!/^[1-9]$/.test(value)) {
                    e.target.value = '';
                }
                this.updatePuzzle();
            });

            // セル選択処理
            cell.addEventListener('click', (e) => {
                this.selectCell(e.target);
            });

            // キーボード操作
            cell.addEventListener('keydown', (e) => {
                this.handleKeyDown(e);
            });

            gridElement.appendChild(cell);
            this.grid.push(cell);
        }
    }

    bindEvents() {
        document.getElementById('new-game').addEventListener('click', () => {
            this.newGame();
        });

        document.getElementById('solve').addEventListener('click', () => {
            this.solvePuzzle();
        });

        document.getElementById('clear').addEventListener('click', () => {
            this.clearPuzzle();
        });

        document.getElementById('validate').addEventListener('click', () => {
            this.validatePuzzle();
        });
    }

    selectCell(cell) {
        if (this.selectedCell) {
            this.selectedCell.classList.remove('selected');
        }
        this.selectedCell = cell;
        cell.classList.add('selected');
        cell.focus();
    }

    handleKeyDown(e) {
        const index = parseInt(e.target.dataset.index);
        const row = Math.floor(index / 9);
        const col = index % 9;

        switch (e.key) {
            case 'ArrowUp':
                e.preventDefault();
                if (row > 0) this.selectCell(this.grid[(row - 1) * 9 + col]);
                break;
            case 'ArrowDown':
                e.preventDefault();
                if (row < 8) this.selectCell(this.grid[(row + 1) * 9 + col]);
                break;
            case 'ArrowLeft':
                e.preventDefault();
                if (col > 0) this.selectCell(this.grid[row * 9 + (col - 1)]);
                break;
            case 'ArrowRight':
                e.preventDefault();
                if (col < 8) this.selectCell(this.grid[row * 9 + (col + 1)]);
                break;
            case 'Delete':
            case 'Backspace':
                if (!e.target.classList.contains('given')) {
                    e.target.value = '';
                    this.updatePuzzle();
                }
                break;
        }
    }

    async newGame() {
        const difficulty = document.getElementById('difficulty').value;
        this.showStatus('パズルを生成中...', 'info');

        try {
            const response = await fetch('/generate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ difficulty: difficulty })
            });

            const data = await response.json();

            if (data.puzzle) {
                this.loadPuzzle(data.puzzle);
                this.showStatus('新しいパズルが生成されました！', 'success');
            } else {
                this.showStatus('パズルの生成に失敗しました', 'error');
            }
        } catch (error) {
            console.error('Error:', error);
            this.showStatus('サーバーエラーが発生しました', 'error');
        }
    }

    loadPuzzle(puzzle) {
        this.originalPuzzle = puzzle.map(row => [...row]);
        this.currentPuzzle = puzzle.map(row => [...row]);

        for (let i = 0; i < 81; i++) {
            const row = Math.floor(i / 9);
            const col = i % 9;
            const cell = this.grid[i];
            const value = puzzle[row][col];

            if (value !== 0) {
                cell.value = value;
                cell.classList.add('given');
                cell.readOnly = true;
            } else {
                cell.value = '';
                cell.classList.remove('given');
                cell.readOnly = false;
            }

            // エラーや解決済みクラスを削除
            cell.classList.remove('error', 'solved');
        }
    }

    updatePuzzle() {
        for (let i = 0; i < 81; i++) {
            const row = Math.floor(i / 9);
            const col = i % 9;
            const value = this.grid[i].value;
            this.currentPuzzle[row][col] = value ? parseInt(value) : 0;
        }

        this.checkCompletion();
    }

    checkCompletion() {
        // すべてのセルが埋まっているかチェック
        const isEmpty = this.currentPuzzle.some(row => row.some(cell => cell === 0));

        if (!isEmpty) {
            this.validatePuzzle().then(isValid => {
                if (isValid) {
                    this.showStatus('おめでとうございます！パズルが完成しました！', 'success');
                    this.markAllCellsAsSolved();
                }
            });
        }
    }

    markAllCellsAsSolved() {
        this.grid.forEach(cell => {
            if (!cell.classList.contains('given')) {
                cell.classList.add('solved');
            }
        });
    }

    async solvePuzzle() {
        this.showStatus('パズルを解いています...', 'info');

        try {
            const response = await fetch('/solve', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ puzzle: this.currentPuzzle })
            });

            const data = await response.json();

            if (data.solvable && data.solution) {
                this.displaySolution(data.solution);
                this.showStatus('パズルが解けました！', 'success');
            } else {
                this.showStatus('このパズルは解けません', 'error');
            }
        } catch (error) {
            console.error('Error:', error);
            this.showStatus('サーバーエラーが発生しました', 'error');
        }
    }

    displaySolution(solution) {
        for (let i = 0; i < 81; i++) {
            const row = Math.floor(i / 9);
            const col = i % 9;
            const cell = this.grid[i];

            if (!cell.classList.contains('given')) {
                cell.value = solution[row][col];
                cell.classList.add('solved');
            }
        }
        this.updatePuzzle();
    }

    clearPuzzle() {
        this.grid.forEach(cell => {
            if (!cell.classList.contains('given')) {
                cell.value = '';
                cell.classList.remove('error', 'solved');
            }
        });
        this.updatePuzzle();
        this.showStatus('パズルをクリアしました', 'info');
    }

    async validatePuzzle() {
        try {
            const response = await fetch('/validate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ puzzle: this.currentPuzzle })
            });

            const data = await response.json();

            if (data.valid) {
                this.showStatus('パズルは有効です！', 'success');
                this.clearErrors();
                return true;
            } else {
                this.showStatus('パズルに間違いがあります', 'error');
                this.highlightErrors();
                return false;
            }
        } catch (error) {
            console.error('Error:', error);
            this.showStatus('サーバーエラーが発生しました', 'error');
            return false;
        }
    }

    clearErrors() {
        this.grid.forEach(cell => {
            cell.classList.remove('error');
        });
    }

    highlightErrors() {
        // 簡単なエラーハイライト実装
        for (let i = 0; i < 81; i++) {
            const row = Math.floor(i / 9);
            const col = i % 9;
            const cell = this.grid[i];
            const value = this.currentPuzzle[row][col];

            if (value !== 0 && this.hasConflict(row, col, value)) {
                cell.classList.add('error');
            } else {
                cell.classList.remove('error');
            }
        }
    }

    hasConflict(row, col, value) {
        // 行の競合をチェック
        for (let c = 0; c < 9; c++) {
            if (c !== col && this.currentPuzzle[row][c] === value) {
                return true;
            }
        }

        // 列の競合をチェック
        for (let r = 0; r < 9; r++) {
            if (r !== row && this.currentPuzzle[r][col] === value) {
                return true;
            }
        }

        // 3x3ボックスの競合をチェック
        const startRow = Math.floor(row / 3) * 3;
        const startCol = Math.floor(col / 3) * 3;

        for (let r = startRow; r < startRow + 3; r++) {
            for (let c = startCol; c < startCol + 3; c++) {
                if ((r !== row || c !== col) && this.currentPuzzle[r][c] === value) {
                    return true;
                }
            }
        }

        return false;
    }

    showStatus(message, type) {
        const status = document.getElementById('status');
        status.innerHTML = `<p>${message}</p>`;
        status.className = `status ${type}`;

        // 3秒後にinfoクラスに戻す
        if (type !== 'info') {
            setTimeout(() => {
                status.className = 'status';
            }, 3000);
        }
    }
}

// ページ読み込み時にゲームを初期化
document.addEventListener('DOMContentLoaded', () => {
    const game = new SudokuGame();

    // 初期パズルを生成
    game.newGame();
});
