.PHONY: help check-cost destroy-all pdf clean

help:
	@echo "Common bootcamp commands:"
	@echo "  make check-cost     Run AWS cost guardrail check"
	@echo "  make destroy-all    Tear down all bootcamp infrastructure (DESTRUCTIVE)"
	@echo "  make pdf            Build the curriculum PDF from docs/guide.typ"
	@echo "  make clean          Remove generated artifacts"

check-cost:
	./scripts/check-free-tier.sh

destroy-all:
	./scripts/destroy-all.sh

pdf:
	typst compile docs/guide.typ pdf/guide.pdf
	@echo "Built pdf/guide.pdf"

clean:
	rm -f pdf/guide.pdf
