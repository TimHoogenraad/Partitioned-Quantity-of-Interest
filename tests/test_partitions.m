function tests = test_partitions
tests = functiontests(localfunctions);
end

function testGridEdgesAreShared(testCase)
x = (0:10).';
p = pqoi.makeGridPartitions(x, 4);

verifyEqual(testCase, p.edgeIndices, [1;5;9;11]);
verifyEqual(testCase, p.indexRanges{1}(end), p.indexRanges{2}(1));
verifyEqual(testCase, p.indexRanges{2}(end), p.indexRanges{3}(1));
verifyTrue(testCase, p.hasShortFinalPartition);
end

function testPartitionIntegralsAddToTotal(testCase)
x = linspace(0, 3, 31).';
q = 2*x.^2 - x + 4;
p = pqoi.makeGridPartitions(x, 7);

values = pqoi.integrate(x, q, p);
verifyEqual(testCase, sum(values), trapz(x, q), 'AbsTol', 1e-12);
end

function testNonuniformGridUsesConsecutiveIntervals(testCase)
x = [0; 0.1; 0.3; 0.8; 1.4; 2.0; 3.0];
p = pqoi.makeGridPartitions(x, 2);

verifyEqual(testCase, p.edgeCoordinates, x([1 3 5 7]));
q = exp(-x);
verifyEqual(testCase, sum(pqoi.integrate(x, q, p)), trapz(x, q), ...
    'AbsTol', 1e-14);
end

function testPhysicalEdgesUseInterpolation(testCase)
x = [0; 0.2; 0.55; 1.0];
q = 3*x + 2;
p = pqoi.makePhysicalPartitions(x, [0; 0.4; 0.75; 1]);

values = pqoi.integrate(x, q, p);
expected = 1.5*diff(p.edgeCoordinates.^2) + 2*diff(p.edgeCoordinates);
verifyEqual(testCase, values, expected, 'AbsTol', 1e-13);
verifyFalse(testCase, all(p.isGridAligned));
verifyEqual(testCase, sum(values), trapz(x, q), 'AbsTol', 1e-13);
end

function testRejectsNonIntegerIntervalCount(testCase)
verifyError(testCase, @() pqoi.makeGridPartitions((0:5).', 2.5), ...
    'MATLAB:makeGridPartitions:expectedInteger');
end
