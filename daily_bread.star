"""
Applet: Daily Bread

Summary: A new Bible-based encouragement every day

Description: Displays a scrolling, Scripture-based message that changes at
local midnight.
"""

load("encoding/json.star", "json")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

DEFAULT_LOCATION = {
    "lat": 41.8781,
    "lng": -87.6298,
    "locality": "Chicago, Illinois",
    "timezone": "America/Chicago",
}

MESSAGES = [
    ("Trust God with your whole heart; let Him direct your path.", "PROVERBS 3:5-6"),
    ("God's mercy is new this morning. Begin again with hope.", "LAMENTATIONS 3:22-23"),
    ("Be still. God is present, powerful, and worthy of your trust.", "PSALM 46:10"),
    ("Let everything you do today be shaped by love.", "1 CORINTHIANS 16:14"),
    ("The Lord is your shepherd; you are not walking alone.", "PSALM 23:1-4"),
    ("Choose courage: God goes with you wherever you go.", "JOSHUA 1:9"),
    ("Bring every worry to God, and receive His guarding peace.", "PHILIPPIANS 4:6-7"),
    ("Your light can help someone see God's goodness today.", "MATTHEW 5:14-16"),
    ("Wait on the Lord. He renews the strength of the weary.", "ISAIAH 40:31"),
    ("Forgive as freely as the Lord has forgiven you.", "COLOSSIANS 3:13"),
    ("God is near to the brokenhearted and saves the crushed in spirit.", "PSALM 34:18"),
    ("Do justice, love mercy, and walk humbly with God.", "MICAH 6:8"),
    ("You are God's workmanship, created to do good.", "EPHESIANS 2:10"),
    ("Seek God's kingdom first; trust Him with what you need.", "MATTHEW 6:33"),
    ("A gentle answer can turn anger away. Speak peace today.", "PROVERBS 15:1"),
    ("God can work even this for good. Keep trusting His purpose.", "ROMANS 8:28"),
    ("Cast your burden on the Lord; He will sustain you.", "PSALM 55:22"),
    ("Love is patient and kind. Practice both today.", "1 CORINTHIANS 13:4"),
    ("Ask God for wisdom; He gives generously.", "JAMES 1:5"),
    ("Rejoice in hope, be patient in trouble, and keep praying.", "ROMANS 12:12"),
    ("God's grace is enough; His strength meets you in weakness.", "2 CORINTHIANS 12:9"),
    ("Encourage someone today and help build them up.", "1 THESSALONIANS 5:11"),
    ("The Lord is your light and salvation. Whom shall you fear?", "PSALM 27:1"),
    ("Clothe yourself with compassion, kindness, humility, and patience.", "COLOSSIANS 3:12"),
    ("Commit your work to the Lord and place your plans in His hands.", "PROVERBS 16:3"),
    ("Walk by faith when you cannot yet see the whole way.", "2 CORINTHIANS 5:7"),
    ("God is our refuge and strength, an ever-present help in trouble.", "PSALM 46:1"),
    ("Do not grow tired of doing good; the harvest will come.", "GALATIANS 6:9"),
    ("Let God's peace rule your heart, and practice gratitude.", "COLOSSIANS 3:15"),
    ("The joy of the Lord is your strength today.", "NEHEMIAH 8:10"),
    ("Nothing can separate you from the love of God in Christ.", "ROMANS 8:38-39"),
]

def _location(config):
    value = config.get("location")
    if value:
        return json.decode(value)
    return DEFAULT_LOCATION

def _seconds_until_midnight(now):
    # The short floor protects against a zero-age cache response at 23:59:59.
    remaining = 86400 - (now.hour * 3600 + now.minute * 60 + now.second)
    return max(30, remaining)

def main(config):
    loc = _location(config)
    now = time.now().in_location(loc["timezone"])
    index = (int(now.format("002")) - 1) % len(MESSAGES)
    message, reference = MESSAGES[index]

    accent = config.get("accent_color") or "#F5B642"
    content = "  " + message + "  •  " + reference + "  "

    return render.Root(
        # A complete marquee is 231 frames for the longest entry. At 50 ms,
        # it finishes in about 11.6 seconds, leaving margin in a 15-second
        # Tidbyt rotation slot.
        delay = 50,
        max_age = _seconds_until_midnight(now),
        child = render.Stack(
            children = [
                render.Box(width = 64, height = 32, color = "#080B14"),
                render.Padding(
                    pad = (2, 2, 0, 0),
                    child = render.Row(
                        children = [
                            render.Stack(
                                children = [
                                    render.Box(width = 9, height = 9),
                                    render.Padding(
                                        pad = (4, 0, 0, 0),
                                        child = render.Box(width = 1, height = 9, color = accent),
                                    ),
                                    render.Padding(
                                        pad = (1, 3, 0, 0),
                                        child = render.Box(width = 7, height = 1, color = accent),
                                    ),
                                ],
                            ),
                            render.Box(width = 2),
                            render.Text(
                                content = "DAILY BREAD",
                                font = "CG-pixel-3x5-mono",
                                color = "#FFFFFF",
                            ),
                        ],
                    ),
                ),
                render.Padding(
                    pad = (0, 12, 0, 0),
                    child = render.Box(
                        width = 64,
                        height = 13,
                        child = render.Marquee(
                            width = 64,
                            child = render.Text(
                                content = content,
                                font = "tom-thumb",
                                color = "#FFFFFF",
                            ),
                        ),
                    ),
                ),
                render.Padding(
                    pad = (2, 26, 0, 0),
                    child = render.Text(
                        content = now.format("Mon 01/02"),
                        font = "tom-thumb",
                        color = accent,
                    ),
                ),
            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Location(
                id = "location",
                name = "Location",
                desc = "Used only to change the message at local midnight.",
                icon = "locationDot",
            ),
            schema.Color(
                id = "accent_color",
                name = "Accent color",
                desc = "Color for the cross and date.",
                icon = "palette",
                default = "#F5B642",
            ),
        ],
    )
