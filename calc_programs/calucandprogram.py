# coding: utf-8
'''
猪俣・山田『計算モデルとプログラミング』森北出版の練習問題とかを写経する人生。
'''

# フィボナッチ数列の関数
#%%
def fibo(n):
    fn = 1
    n1 = 1
    n2 = 0
    while n > 1:
        fn = n1 + n2
        n2 = n1
        n1 = fn
        n = n - 1
    return fn
#%%
for i in range(0,10):
    print(fibo(i))

# 自動販売機アルゴリズム？