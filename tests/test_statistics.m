function tests = test_statistics
tests = functiontests(localfunctions);
end

function testConstantFieldStatistics(testCase)
x = linspace(0, 1, 17).';
p = pqoi.makeGridPartitions(x, 4);
stats = pqoi.partitionStatistics(x, 3*ones(size(x)), p);

verifyEqual(testCase, stats.mean, 3*ones(4,1), 'AbsTol', 1e-14);
verifyEqual(testCase, stats.std, zeros(4,1), 'AbsTol', 1e-14);
verifyEqual(testCase, stats.rms, 3*ones(4,1), 'AbsTol', 1e-14);
verifyEqual(testCase, stats.integral, 3*stats.length, 'AbsTol', 1e-14);
end

function testStructFields(testCase)
x = linspace(0, 2, 9).';
p = pqoi.makeGridPartitions(x, 4);
fields.u = x;
fields.u2 = x.^2;
stats = pqoi.partitionStatistics(x, fields, p);

verifyTrue(testCase, isfield(stats, 'u'));
verifyTrue(testCase, isfield(stats, 'u2'));
verifySize(testCase, stats.u.mean, [2 1]);
end

function testMultidimensionalField(testCase)
x = linspace(0, 1, 11).';
field = [x, 2*x, 3*x];
p = pqoi.makeGridPartitions(x, 5);
values = pqoi.integrate(x, field, p);

verifySize(testCase, values, [2 3]);
verifyEqual(testCase, sum(values,1), [0.5 1 1.5], 'AbsTol', 1e-13);
end

function testSampleWeightingOption(testCase)
x = [0; 0.1; 0.4; 1.0];
p = pqoi.makeGridPartitions(x, 3);
stats = pqoi.partitionStatistics(x, x, p, 'Weighting', 'sample');

verifyEqual(testCase, stats.mean, mean(x), 'AbsTol', 1e-14);
verifyEqual(testCase, stats.std, std(x), 'AbsTol', 1e-14);
end
