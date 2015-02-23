% gpucbProbabilisticPeakRanks(NUM_TRAIN,NUM_TRIALS,GRIDDING_PARAM,SCALE_PARAM)

function gpucbProbabilisticPeakRanksUniformPrior(NUM_TRAIN,NUM_TRIALS,GRIDDING_PARAM,SCALE_PARAM)

[datavec, Xgrid, Ygrid] = gaussianMixturesForGPUCB(GRIDDING_PARAM);
filename = 'gpucb-hotspot-model'
isTrained = 0;

ymax = max(datavec(:,end));
STD = ymax/100;
N = size(datavec, 1);
P = randperm(N);
ind = P(1:NUM_TRAIN);

trainDataX_ = datavec(ind,1:2);
Y = datavec(ind,end) + STD.*randn(length(N),1);

for i=1:NUM_TRIALS
    
    testData = datavec(:,1:2);
    par = [SCALE_PARAM STD];
    covfunc = @covSEiso;
    
    hyp.cov = log(par);
    likfunc = @likGauss;
    hyp.lik = log(0.1);
    if(isTrained == 0)
        [normConstants, X] = normalizeColumnJD(trainDataX_,[]);
        hyp = minimize(hyp, @gp, -40, @infExact, [], covfunc, likfunc, X, Y);
        save(filename,'hyp','covfunc','likfunc','normConstants');
        isTrained = 0;
    end
    load(filename)
    [normConstants, X] = normalizeColumnJD(trainDataX_,[]);
    [~, Xtest] = normalizeColumnJD(testData,normConstants);
    [mSP, s2SP] = gp(hyp, @infExact, [], covfunc, likfunc, X, Y, Xtest);
    predictedY = mSP;
    d = s2SP;
    
    
    s0 = subplot(141)
    title(['True: ' num2str(i)],'fontsize',12)
    pcolor(Xgrid,Ygrid,reshape(datavec(:,3),GRIDDING_PARAM,GRIDDING_PARAM))
    shading interp
    %     scatter(datavec(:,1),datavec(:,2),10,datavec(:,3),'s')
    hold on
    plot(trainDataX_(:,1),trainDataX_(:,2),'r.','markersize',20);
    plot(trainDataX_(end,1),trainDataX_(end,2),'w.','markersize',30);
    colorbar
    
    
    s1 = subplot(142)
    title('mean  ','fontsize',12);
    pcolor(Xgrid,Ygrid,reshape(predictedY,GRIDDING_PARAM,GRIDDING_PARAM))
    shading interp
    colorbar
    hold on;
    hold on
    plot(trainDataX_(:,1),trainDataX_(:,2),'r.','markersize',20);
    plot(trainDataX_(end,1),trainDataX_(end,2),'w.','markersize',30);
    
    
    s2 = subplot(143)
    title('std-dev  ','fontsize',12);
    pcolor(Xgrid,Ygrid,reshape(sqrt(d),GRIDDING_PARAM,GRIDDING_PARAM))
    shading interp
    colorbar
    caxis auto
    hold on
    plot(trainDataX_(:,1),trainDataX_(:,2),'r.','markersize',20);
    plot(trainDataX_(end,1),trainDataX_(end,2),'w.','markersize',30);
    
    stdComponent = @(t,y)(gpucbBeta(t)*sqrt(y));
    gpucbFunc = @(x,y,t)(x + stdComponent(t,y));
    %gpucbFunc = @(x,y,t)(sqrt(y));
    utils = zeros(N,1);
    
    for j=1:N
        utils(j) = gpucbFunc(predictedY(j),d(j),i);
    end
    [~,indMax] = max(utils);
    
    s2 = subplot(144)
    title('utils  ','fontsize',12);
    pcolor(Xgrid,Ygrid,reshape(utils,GRIDDING_PARAM,GRIDDING_PARAM))
    shading interp
    colorbar
    hold on;
    plot(trainDataX_(:,1),trainDataX_(:,2),'r.','markersize',20);
    plot(trainDataX_(end,1),trainDataX_(end,2),'w.','markersize',30);
    
    
    
    trainDataX_ = [trainDataX_; datavec(indMax,1:2)];
    Y = [Y;datavec(indMax,end)+STD.*randn(1,1)];
    
    pause(0.01)
    cla(s0)
    cla(s1)
    cla(s2)
end
subplot(131)
title(['True: ' num2str(i)],'fontsize',12)
pcolor(Xgrid,Ygrid,reshape(datavec(:,3),GRIDDING_PARAM,GRIDDING_PARAM))
shading interp
%alpha(0.2)
%     scatter(datavec(:,1),datavec(:,2),10,datavec(:,3),'s')
hold on
plot(trainDataX_(:,1),trainDataX_(:,2),'r.','markersize',20);
plot(trainDataX_(end,1),trainDataX_(end,2),'k.','markersize',20);
colorbar


s1 = subplot(132)
title('mean  ','fontsize',12);
pcolor(Xgrid,Ygrid,reshape(predictedY,GRIDDING_PARAM,GRIDDING_PARAM))
shading interp

%     scatter(testData(:,1),testData(:,2),10,predictedY,'s')
colorbar
hold on;
plot(trainDataX_(:,1),trainDataX_(:,2),'r.','markersize',20);
plot(trainDataX_(:,1),trainDataX_(:,2),'w-','markersize',20);
plot(trainDataX_(end,1),trainDataX_(end,2),'w.','markersize',20);
%     c_ = caxis
%caxis([0 0.03]);


s2 = subplot(133)
title('std-dev  ','fontsize',12);
pcolor(Xgrid,Ygrid,reshape(sqrt(d),GRIDDING_PARAM,GRIDDING_PARAM))
plot(trainDataX_(:,1),trainDataX_(:,2),'r.','markersize',20);
shading interp


%     scatter(testData(:,1),testData(:,2),10,sqrt(d),'o')
colorbar
hold on;
plot(trainDataX_(end,1),trainDataX_(end,2),'k.','markersize',10);

end