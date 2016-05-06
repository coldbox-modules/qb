component displayname='QueryUtils' {
    public struct function extractBinding(required any value) {
        var binding = {};

        if (isStruct(arguments.value)) {
            binding = arguments.value;
            arguments.value = arguments.value.value;
        }

        if (! structKeyExists(binding, 'value')) {
            binding.value = arguments.value;
        }

        return binding;
    }
}