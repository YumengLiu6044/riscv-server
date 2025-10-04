// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from "vscode";

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {
	console.log("RISC-V Assembly extension activated!");

	// Override only assembler directives to purple
	const config = vscode.workspace.getConfiguration();
	const currentOverrides =
		config.get<any>("editor.tokenColorCustomizations") || {};

	// Copy existing textMateRules if any
	const textMateRules = currentOverrides.textMateRules
		? [...currentOverrides.textMateRules]
		: [];

	// Add our directive override
	textMateRules.push({
		scope: "keyword.directive",
		settings: {
			foreground: "#800080", // Purple
			fontStyle: "bold",
		},
	});

	// Update workspace settings
	config.update(
		"editor.tokenColorCustomizations",
		{ ...currentOverrides, textMateRules },
		vscode.ConfigurationTarget.Global
	);
}

// This method is called when your extension is deactivated
export function deactivate() {}
