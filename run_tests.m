function results = run_tests
%RUN_TESTS Run the complete pQoI test suite.

root = fileparts(mfilename('fullpath'));
addpath(root);
results = runtests(fullfile(root, 'tests'), 'IncludeSubfolders', true);
disp(table(results));
assertSuccess(results);
end
