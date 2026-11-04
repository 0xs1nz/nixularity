import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: page

    property real marginLeft: 0
    property real marginRight: 10
    property real marginTop: 0
    property real marginBottom: 0

    readonly property string terminal: "kitty"
    readonly property string repoPath: Quickshell.env("HOME") + "/sys/nixos"

    property string statusText: ""
    property string flatpakCount: "CHECKING…"

    function inTerminal(title, script) {
        const fullScript =
            "cd " + JSON.stringify(repoPath) + " && " + script
            + "\nresult=$?"
            + "\nif [ \"$result\" -eq 0 ]; then"
            + "\n  printf '\\n\\033[1;32m[SUCCESS]\\033[0m Command completed successfully.\\n'"
            + "\nelse"
            + "\n  printf '\\n\\033[1;31m[FAILED]\\033[0m Command failed with exit code %s.\\n' \"$result\""
            + "\nfi"
            + "\nread -r -p 'Press Enter to close... '"
            + "\nexit \"$result\""

        return [terminal, "--title", title, "bash", "-lc", fullScript]
    }

    function run(title, script) {
        if (runner.running) {
            statusText = "ANOTHER COMMAND IS RUNNING"
            return
        }

        statusText = title.toUpperCase() + " RUNNING…"
        runner.title = title
        runner.command = inTerminal(title, script)
        runner.running = true
    }

    readonly property string flakeUpdateScript:
        "nix --extra-experimental-features 'nix-command flakes' flake update"

    readonly property string buildScript:
        "nix --extra-experimental-features 'nix-command flakes' build --show-trace --no-link .#nixosConfigurations.nixos.config.system.build.toplevel"

    readonly property string flatpakUpdateScript:
        "flatpak update -y"

    Process {
        id: runner

        property string title: ""

        onExited: exitCode => {
            page.statusText = runner.title.toUpperCase()
                + (exitCode === 0 ? " — FINISHED" : " — FAILED")
            refreshTimer.restart()
        }
    }

    Process {
        id: flatpakCheck

        command: [
            "sh", "-c",
            "if command -v flatpak >/dev/null 2>&1; then "
            + "flatpak remote-ls --updates 2>/dev/null | wc -l; "
            + "else echo N/A; fi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim()
                const n = parseInt(result)

                page.flatpakCount = result === "N/A"
                    ? "NOT INSTALLED"
                    : (isNaN(n) ? "UNAVAILABLE" : (n === 0 ? "UP TO DATE" : n + " PENDING"))
            }
        }
    }

    function refresh() {
        flatpakCount = "CHECKING…"
        flatpakCheck.running = true
    }

    Timer {
        id: refreshTimer
        interval: 700
        onTriggered: page.refresh()
    }

    component SectionTitle: Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.textSizeSection
        font.bold: true
        font.letterSpacing: 2
    }

    component GroupLabel: Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.textSizeGroup
        font.bold: true
        font.letterSpacing: 1
    }

    component Card: Rectangle {
        id: card

        default property alias contentData: cardColumn.data

        width: parent.width
        height: cardColumn.implicitHeight + 28
        radius: Theme.radius
        color: "#00000000"
        border.width: 1
        border.color: Theme.border

        Column {
            id: cardColumn
            x: 14
            y: 14
            width: parent.width - 28
            spacing: 16
        }
    }

    component SmallButton: Rectangle {
        id: sb

        property string label: ""
        property bool current: false
        property bool buttonEnabled: true

        signal clicked()

        height: 30
        radius: Theme.radius
        opacity: buttonEnabled ? 1.0 : 0.35

        color: current
            ? Theme.alpha(Theme.accent, 0.10)
            : (sbMouse.containsMouse
                ? Theme.alpha(Theme.accent, 0.08)
                : "#00000000")

        border.width: 1
        border.color: current || sbMouse.containsMouse
            ? Theme.accent
            : Theme.border

        Text {
            anchors.centerIn: parent
            text: sb.label
            color: sb.current ? Theme.accent : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.textSizeBody
            font.bold: true
            font.letterSpacing: 1
        }

        MouseArea {
            id: sbMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: sb.buttonEnabled
            cursorShape: Qt.PointingHandCursor
            onClicked: sb.clicked()
        }
    }

    Flickable {
        id: flick

        anchors.fill: parent
        anchors.leftMargin: page.marginLeft
        anchors.rightMargin: page.marginRight
        anchors.topMargin: page.marginTop
        anchors.bottomMargin: page.marginBottom

        contentWidth: width
        contentHeight: content.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: content

            width: flick.width
            spacing: 14

            Text {
                text: "UPDATES"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.textSizeTitle
                font.letterSpacing: 3
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // NIXOS
            Column {
                width: parent.width
                spacing: 10

                SectionTitle {
                    text: "NIXOS"
                }

                Card {
                    Column {
                        width: parent.width
                        spacing: 8

                        GroupLabel {
                            text: "FLAKE INPUTS"
                        }

                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: "Update the locked NixOS and Home Manager inputs in flake.lock."
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textSizeSmall
                        }

                        SmallButton {
                            width: parent.width
                            label: "UPDATE FLAKE INPUTS"
                            buttonEnabled: !runner.running
                            onClicked: page.run(
                                "Update flake inputs",
                                page.flakeUpdateScript
                            )
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.border
                        }

                        GroupLabel {
                            text: "SYSTEM BUILD"
                        }

                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: "Build and check the NixOS configuration without activating it. Your running system will not change."
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textSizeSmall
                        }

                        SmallButton {
                            width: parent.width
                            label: "BUILD SYSTEM"
                            buttonEnabled: !runner.running
                            onClicked: page.run(
                                "Build NixOS configuration",
                                page.buildScript
                            )
                        }

                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: "This does NOT run nixos-rebuild switch."
                            color: Theme.accent2
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textSizeSmall
                        }
                    }
                }
            }

            // FLATPAK
            Column {
                width: parent.width
                spacing: 10

                Item {
                    width: parent.width
                    height: 26

                    SectionTitle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "FLATPAK"
                    }

                    SmallButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 90
                        label: "REFRESH"
                        buttonEnabled: !runner.running
                        onClicked: page.refresh()
                    }
                }

                Card {
                    Column {
                        width: parent.width
                        spacing: 10

                        Row {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "APPLICATION UPDATES"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textSizeBody
                                font.bold: true
                            }

                            Item {
                                width: 1
                                height: 1
                            }

                            Text {
                                text: page.flatpakCount
                                color: Theme.textDim
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textSizeSmall
                            }
                        }

                        SmallButton {
                            width: parent.width
                            label: "UPDATE FLATPAK"
                            buttonEnabled: !runner.running
                                && page.flatpakCount !== "NOT INSTALLED"
                            onClicked: page.run(
                                "Flatpak update",
                                page.flatpakUpdateScript
                            )
                        }
                    }
                }
            }

            // DOTFILES
            Column {
                width: parent.width
                spacing: 10

                SectionTitle {
                    text: "DOTFILES"
                }

                Card {
                    Column {
                        width: parent.width
                        spacing: 8

                        GroupLabel {
                            text: "43PR CONFIGURATION"
                        }

                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: "The original Arch-based updater scripts are disabled on NixOS. The upstream repository is left untouched; desktop configuration changes will be managed through this NixOS repository."
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textSizeSmall
                        }
                    }
                }
            }

            Text {
                visible: page.statusText.length > 0
                width: parent.width
                wrapMode: Text.WordWrap
                text: page.statusText
                color: Theme.accent2
                font.family: Theme.fontFamily
                font.pixelSize: Theme.textSizeSmall
                font.letterSpacing: 1
            }
        }
    }

    Component.onCompleted: page.refresh()
}
