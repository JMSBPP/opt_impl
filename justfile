set shell := ["bash", "-cu"]

# Run the full local verification gate.
verify:
    pack typecheck opt_impl
    pack test opt_impl

# Typecheck the Idris library only.
typecheck:
    pack typecheck opt_impl

# Run the Idris test executable.
test:
    pack test opt_impl
