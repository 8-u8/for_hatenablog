// stan code for penguins data.
// single hierarchical regression model for study. model is below:
// bill_length_mm ~ flipper_length_mm + (1 + flipper_length_mm | species)

data{
  int N;                        // rows of data
  int<lower=1> J;               // number of species
  int<lower=0, upper=J> grp[N]; // species each individuals
  
  real<lower=0> X[N];   // flipper_length_mm
  real<lower=0> y[N];  // bill_length_mm
}

parameters{
  // hyper prior dist parameters
  // real a0;
  // real b0;
  /*non-negative constraint for intercept and coefficient*/
  real/*<lower=0>*/ a_ind; // intercept individuals
  real/*<lower=0>*/ b_ind; // coefficient individuals 
  
  real/*<lower=0>*/ a_grp[J]; // intercept each groups(random effect)
  real/*<lower=0>*/ b_grp[J]; // coefficient each groups(random effect)
  
  real<lower=0> sigma_a;
  real<lower=0> sigma_b;
  real<lower=0> sigma_all;

}

transformed parameters{
  real a_all[J];
  real b_all[J];
  real mu[N];
  
  for(j in 1:J){
    /*
    Because a_ind, a_grp, b_ind, and b_grp has 
    non-negative constraint, a_all and b_all are 
    also non-negative, theoretically...
    */
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