// くちばしの長さを翼の長さで回帰するモデル。
// 翼の長さは種類で異なる。
// 種類は多項分布に従うように持っていきたい。

data{
  int N; // データの数
  int<lower=1> J; // グループの数(3？)
  int<lower=0, upper=J> grp[N]; // 個体別のグループ
  
  int X[N]; // 説明変数
  real y[N];  // 目的変数
}

parameters{
  // real a0;
  // real b0;
  
  real a_ind;
  real b_ind;
  
  real a_grp[J];
  real b_grp[J];
  
  real<lower=0> sigma_a;
  real<lower=0> sigma_b;
  real<lower=0> sigma_all;

}

transformed parameters{
  real a_all[J];
  real b_all[J];
  real mu[N];
  
  for(j in 1:J){
    a_all[j] = a_ind + a_grp[j];
    b_all[j] = b_ind + b_grp[j];
  }
  for(n in 1:N){
    mu[n] = a_all[grp[n]] + b_all[grp[n]] * X[n];
  }
}

model{
  for(j in 1:J){
    a_grp[j] ~ normal(0, sigma_a);
    b_grp[j] ~ normal(0, sigma_b);
  }
  for(n in 1:N){
    y[n] ~ normal(mu[n], sigma_all);
  }

}

generated quantities{
  real y_pred[N];
  for(n in 1:N){
    y_pred[n] = normal_rng(mu[n], sigma_all);
  }
}