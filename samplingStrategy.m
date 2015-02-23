function samplingStrategies = samplingStrategy(DIVISOR,scoringMethod,name,modelingMethod,samplingMethod  ,param,inputDimensions,outputDimension)
samplingStrategies.divisorIndex = DIVISOR;
samplingStrategies.scoringMethod = scoringMethod;
samplingStrategies.name = name;
samplingStrategies.modelingMethod = modelingMethod;
samplingStrategies.samplingMethod = samplingMethod;
samplingStrategies.param = param;
samplingStrategies.inputDimensions = inputDimensions;
samplingStrategies.outputDimension = outputDimension;
end