function r = cw4_forceSameFields(r, template)
% Forces candidate structs to have the same fields and field order.

templateFields = fieldnames(template);
rFields = fieldnames(r);

missingFields = setdiff(templateFields, rFields);
for k = 1:numel(missingFields)
    r.(missingFields{k}) = template.(missingFields{k});
end

extraFields = setdiff(fieldnames(r), templateFields);
if ~isempty(extraFields)
    r = rmfield(r, extraFields);
end

r = orderfields(r, template);

end
