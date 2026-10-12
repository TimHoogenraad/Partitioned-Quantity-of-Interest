function tests = test_symmetry
tests = functiontests(localfunctions);
end

function testFoldsSymmetricAndAntisymmetricProfiles(testCase)
x = linspace(-1, 1, 9).';
profile.coordinate = x;
profile.profiles.symmetric = x.^2;
profile.profiles.antisymmetric = x;

folded = pqoi.foldSymmetry(profile);
verifyEqual(testCase, folded.coordinate, linspace(0,1,5).', 'AbsTol', 1e-14);
verifyEqual(testCase, folded.profiles.symmetric, x(1:5).^2, 'AbsTol', 1e-14);
verifyEqual(testCase, folded.profiles.antisymmetric, x(1:5), 'AbsTol', 1e-14);
end

function testRejectsEvenGrid(testCase)
profile.coordinate = linspace(0, 1, 8).';
profile.profiles.q = profile.coordinate;
verifyError(testCase, @() pqoi.foldSymmetry(profile), ...
    'pqoi:EvenSymmetryGrid');
end
