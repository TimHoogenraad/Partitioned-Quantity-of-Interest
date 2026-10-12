function tests = test_numerical_compatibility
tests = functiontests(localfunctions);
end

function testKSSharedEdgePartitionFormula(testCase)
% Verify the shared-edge KS space-time integral formulation.
x = linspace(0, 8, 17).';
t = linspace(0, 4, 9);
u = sin(x) * cos(t) + 0.2*cos(2*x) * sin(t);
profile = trapz(t, pqoi.qoi.ks.instantaneousEnergy(struct('u',u)), 2) / t(end);

nPartitions = 4;
referenceEdges = round(linspace(1, numel(x), nPartitions+1));
referenceValues = zeros(nPartitions,1);
for p = 1:nPartitions
    indices = referenceEdges(p):referenceEdges(p+1);
    referenceValues(p) = ...
        trapz(t, trapz(x(indices), 0.5*u(indices,:).^2, 1)) / t(end);
end

partitions = pqoi.makeGridPartitions(x, (numel(x)-1)/nPartitions);
actual = pqoi.integrate(x, profile, partitions);
verifyEqual(testCase, actual, referenceValues, 'AbsTol', 2e-14);
end

function testChannelPhysicalEdgeFallback(testCase)
% Verify integration with interpolated off-grid physical edges.
y = [0; 0.07; 0.21; 0.46; 0.72; 1.0];
value = exp(-y) + y.^2;
edges = linspace(0, 1, 5).';
referenceValues = zeros(4,1);
for p = 1:4
    a = edges(p);
    b = edges(p+1);
    mask = y > a & y < b;
    yp = [a; y(mask); b];
    referenceValues(p) = trapz(yp, interp1(y, value, yp, 'linear'));
end

partitions = pqoi.makePhysicalPartitions(y, edges);
actual = pqoi.integrate(y, value, partitions, 'Interpolation', 'linear');
verifyEqual(testCase, actual, referenceValues, 'AbsTol', 1e-14);
end

function testComparisonUsesReferenceTotalNormalization(testCase)
xReference = linspace(0, 1, 101).';
xApproximation = linspace(0, 1, 17).';
reference.coordinate = xReference;
reference.profiles.q = 2+xReference;
approximation.coordinate = xApproximation;
approximation.profiles.q = 1.1*(2+xApproximation);
partitions = pqoi.makeGridPartitions(xApproximation, 4);

result = pqoi.compare(reference, approximation, partitions);
verifyEqual(testCase, result.profiles.q.globalError, 10, 'AbsTol', 1e-12);
verifyEqual(testCase, sum(result.profiles.q.error), 10, 'AbsTol', 1e-12);
end
