function profile = computeProfile(data, definition, varargin)
%COMPUTEPROFILE Evaluate an application-specific QoI definition.
%   DEFINITION is a function handle accepting DATA followed by any extra
%   arguments. This keeps the partition core independent of each solver.

if ~isa(definition, 'function_handle')
    error('pqoi:InvalidDefinition', 'definition must be a function handle.');
end
profile = definition(data, varargin{:});
if ~isnumeric(profile)
    error('pqoi:InvalidProfile', 'A QoI definition must return a numeric array.');
end
end
