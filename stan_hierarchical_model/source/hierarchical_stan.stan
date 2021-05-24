// くちばしの長さを翼の長さで回帰するモデル。
// 翼の長さは種類で異なる。
// 種類は多項分布に従うように持っていきたい。

data{
  int N; // データの数
  int<lower=1> K; // 個体の説明変数の数(今回は1)
  int<lower=1> J; // グループの数(3？)
  int<lower=1> L; // グループの説明変数の数(今回は1)
  
  int<lower=0, upper=1> jj[N]; // 個体別のグループ
  
  matrix[N,K] x; // 説明変数の計画行列
  row_vector[L] u[J]; // グループの説明変数
  vector[N] y;  // 目的変数
}

parameters{
 corr_matrix[K] Omega; // 相関行列
 vector<lower=0>[K] tau; // スケール(事前分布)
 
 matrix[L, K] gamma;
 vector[N] alpha;
 vector[K] beta[J];
 real<lower=0> sigma;
 
}

model{
  // hyper-prior parameter
  // 多項分布にするならちょっと変える必要ある
  tau ~ cauchy(0, 0.25);
  Omega ~ lkj_corr(2);
  
  
  {//level2 model
    row_vector[K] u_gamma[J];
    for(j in 1:J)
      u_gamma[j] = u[j] * gamma;
    beta ~ multi_normal(u_gamma, quad_form_diag(Omega, tau));
  }//level2 end
  
  //level1 model
  for(n in 1:N)
    y[n] ~ normal(x[n] * beta[jj[n]] + alpha[jj[n]], sigma);
  //level1 end
}