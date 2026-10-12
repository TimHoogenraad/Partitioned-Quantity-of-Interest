function tests = test_qoi_modules
tests = functiontests(localfunctions);
end

function testKSDefinitions(testCase)
data.u = [-2; 0; 2];
data.dudx = [1; -2; 3];
data.meanU = [1; 2; 3];
data.meanU2 = [2; 5; 10];

verifyEqual(testCase, pqoi.qoi.ks.instantaneousEnergy(data), [2;0;2]);
verifyEqual(testCase, pqoi.qoi.ks.enstrophy(data), [1;4;9]);
verifyEqual(testCase, pqoi.qoi.ks.totalEnergy(data), [1;2.5;5]);
verifyEqual(testCase, pqoi.qoi.ks.meanEnergy(data), 0.5*[1;4;9]);
verifyEqual(testCase, pqoi.qoi.ks.fluctuatingEnergy(data), 0.5*[1;1;1]);
end

function testChannelDefinitions(testCase)
data.meanU = [1;2];
data.meanV = [0.1;0.2];
data.meanW = [0;0];
data.meanU2 = [2;6];
data.meanV2 = [0.2;0.5];
data.meanW2 = [0.3;0.4];
data.meanUV = [-0.2;-0.3];
data.dUdy = [4;3];
data.nu = 0.1;
data.tauSgs = [0.02;0.03];

uv = data.meanUV-data.meanU.*data.meanV;
verifyEqual(testCase, pqoi.qoi.channel.totalShearStress(data), ...
    data.nu*data.dUdy-uv+data.tauSgs, 'AbsTol', 1e-14);
verifyEqual(testCase, pqoi.qoi.channel.production(data), ...
    -(uv+data.tauSgs).*data.dUdy, 'AbsTol', 1e-14);
verifyEqual(testCase, pqoi.qoi.channel.production(data, 'IncludeSGS', false), ...
    -uv.*data.dUdy, 'AbsTol', 1e-14);
end

function testCustomDefinition(testCase)
data.value = (1:4).';
profile = pqoi.computeProfile(data, @(d, scale) scale*d.value.^3, 2);
verifyEqual(testCase, profile, 2*(1:4)'.^3);
end
