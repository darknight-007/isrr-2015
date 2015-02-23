function datavector = gmmMultiPeakModelVectorized


rng default;  % For reproducibility
mu1 = [1 2];
sigma1 = [1 .2; .2 02];
mu2 = [-1 -2];
sigma2 = [2 0; 0 1];
X = [mvnrnd(mu1,sigma1,2000);mvnrnd(mu2,sigma2,1000)];

scatter(X(:,1),X(:,2),10,'ko')


datavector = X;

end