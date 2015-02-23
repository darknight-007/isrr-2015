function  [data,X,Y] = gaussianMixturesForGPUCB(NUMPOINTS)
mu = [1 2;-3 -5;6 6];
sigma = cat(3,[2 0;0 .5],[1 0;0 1],[1 0;0 1]);
p = [1 2 2];
obj = gmdistribution(mu,sigma,p);
%ezsurf(@(x,y)pdf(obj,[x y]),[-10 10],[-10 10])

[X,Y] = meshgrid(linspace(-10,10,NUMPOINTS),linspace(-10,10,NUMPOINTS));
inpvecX = reshape(X,numel(X),1);
inpvecY = reshape(Y,numel(Y),1);
func = @(x,y)pdf(obj,[x y]);


datavec = zeros(numel(inpvecX),1);
parfor i = 1:numel(inpvecX)
   datavec(i) = func(inpvecX(i),inpvecY(i));
end
%normalizeWithinRange(10,500,datavec)
%scatter(inpvecX,inpvecY,10,datavec,'o')
data = [inpvecX inpvecY datavec];
end