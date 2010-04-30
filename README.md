## Faster::OpenStruct

Up to 40 (!) times more memory efficient version of OpenStruct

Differences from Ruby MRI OpenStruct:

1. Doesn't `dup` passed initialization hash (NOTE: only reference to hash is stored)

2. Doesn't convert hash keys to symbols (by default string keys are used,
   with fallback to symbol keys)

3. Creates methods on the fly on `OpenStruct` class, instead of singleton class.
   Uses `module_eval` with string to avoid holding scope references for every method.

4. Refactored, crud clean, spec covered :)
