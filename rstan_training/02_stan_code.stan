data {
  int<lower=0> N; // Number of observations
  int<lower=0> X[N]; // Observations
  int M_max;
}

parameters {
  real<lower=0> lambda;
  real alpha;
}


transformed parameters{
  real p;
  real q;
    p = inv_logit(alpha);
    q = 1 - p;
}

model {
  alpha ~ normal(0, 100);
  for(n in 1:N){
    vector[M_max - X[n]+1] lp;
    for(m in X[n]:M_max){
      lp[m-X[n]+1] = poisson_lpmf(m | lambda) + binomial_lpmf(X[n] | m, p);
      }
    target += log_sum_exp(lp);
    }
}
// how to generate above model?
// generated quantities{
//   real<lower=0> X_test[100];
//   for(n in 1:100){
//     X_test[n] = binomial_rng(100, p);
//   }
// }