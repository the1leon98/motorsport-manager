extends Node
class_name MoneyFormat
# Formatiert Renn-Mark (RM)-Beträge mit Tausenderpunkten. Reine Utility ohne
# Bezug zum Spielstand – bewusst getrennt von GameState, damit Screens nicht
# den kompletten Session-State importieren müssen, nur um einen Betrag
# anzuzeigen.
# Reine Utility-Klasse: MoneyFormat.format(amount) -> String


static func format(amount: float) -> String:
	var rounded: int = int(round(amount))
	var negative: bool = rounded < 0
	var digits: String = str(abs(rounded))
	var grouped: String = ""
	var count: int = 0
	for i in range(digits.length() - 1, -1, -1):
		grouped = digits[i] + grouped
		count += 1
		if count % 3 == 0 and i != 0:
			grouped = "." + grouped
	return ("-" if negative else "") + grouped
