using System.Security;

class Day7
{
    static void Main()
    {
        var lines = File.ReadLines("day7.txt");

        SortedSet<Hand> hands = [];
        int i = 0;
        Random r = new();
        foreach (var line in lines)
        {
            string[] parts = line.Split(' ');
            Hand h = new(parts[0], long.Parse(parts[1]), Part.TWO);
            hands.Add(h);

            if (parts[0].Contains('J') && r.NextDouble() < 1.0 / 3.0)
            {
                Console.WriteLine(h);
            }

            i++;
        }

        Console.WriteLine("------------------------------------\nRANKING\n--------------------------------");

        long sum = 0;
        long rank = 1;
        foreach (var h in hands)
        {
            sum += rank * h.bid;
            rank++;
            if (rank % 3 == 0) Console.WriteLine(h);
        }

        // Part 2:
        // 248696167 - too low
        Console.WriteLine(sum);
    }
}

enum Part
{
    ONE, TWO
}

class Hand : IComparable<Hand>
{
    public enum Type : int
    {
        FIVE_OF_A_KIND = 7,
        FOUR_OF_A_KIND = 6,
        FULL_HOUSE = 5,
        THREE_OF_A_KIND = 4,
        TWO_PAIR = 3,
        ONE_PAIR = 2,
        HIGH_CARD = 1
    };

    public string cardOrder;
    public Type type = Type.HIGH_CARD;
    public long bid;

    public Hand(string cardOrder, long bid, Part part)
    {
        this.cardOrder = cardOrder;
        this.bid = bid;
        switch (part)
        {
            case Part.ONE: CalculateType1(cardOrder); break;
            case Part.TWO: CalculateType2(cardOrder); break;
        }

    }

    public override string ToString()
    {
        return "Hand: " + cardOrder + ", type: " + type;
    }

    private void CalculateType1(string cardOrder)
    {
        var cards = new Dictionary<char, int>();

        foreach (var c in cardOrder)
        {
            cards[c] = cards.TryGetValue(c, out int value) ? value + 1 : 1;
        }

        var sortedCards = from entry in cards orderby entry.Value descending select entry;

        foreach (var (c, n) in sortedCards)
        {
            if (n == 5)
            {
                type = Type.FIVE_OF_A_KIND;
            }
            else if (n == 4)
            {
                type = Type.FOUR_OF_A_KIND;
            }
            else if (n == 3)
            {
                type = Type.THREE_OF_A_KIND;
            }
            else if (n == 2)
            {
                if (type == Type.THREE_OF_A_KIND)
                {
                    type = Type.FULL_HOUSE;
                }
                else if (type == Type.ONE_PAIR)
                {
                    type = Type.TWO_PAIR;
                }
                else
                {
                    type = Type.ONE_PAIR;
                }
            }
        }
    }

    private void CalculateType2(string cardOrder)
    {
        var cards = new Dictionary<char, int>();
        int j = 0;

        foreach (var c in cardOrder)
        {
            if (c == 'J') { j++; }
            else
            {
                cards[c] = cards.TryGetValue(c, out int value) ? value + 1 : 1;
            }
        }

        var sortedCards = from entry in cards orderby entry.Value descending select entry;

        foreach (var (c, n) in sortedCards)
        {
            if (n == 5)
            {
                type = Type.FIVE_OF_A_KIND;
            }
            else if (n == 4)
            {
                type = Type.FOUR_OF_A_KIND;
            }
            else if (n == 3)
            {
                type = Type.THREE_OF_A_KIND;
            }
            else if (n == 2)
            {
                if (type == Type.THREE_OF_A_KIND)
                {
                    type = Type.FULL_HOUSE;
                }
                else if (type == Type.ONE_PAIR)
                {
                    type = Type.TWO_PAIR;
                }
                else
                {
                    type = Type.ONE_PAIR;
                }
            }
        }

        // Now update with j count
        if (j >= 4)
        {
            type = Type.FIVE_OF_A_KIND;
        }
        else if (j == 3)
        {
            if (type == Type.ONE_PAIR)
            {
                type = Type.FIVE_OF_A_KIND;
            }
            else
            {
                type = Type.FOUR_OF_A_KIND;
            }
        }
        else if (j == 2)
        {
            if (type == Type.THREE_OF_A_KIND)
            {
                type = Type.FIVE_OF_A_KIND;
            }
            else if (type == Type.ONE_PAIR)
            {
                type = Type.FOUR_OF_A_KIND;
            }
            else
            {
                type = Type.THREE_OF_A_KIND;
            }
        }
        else if (j == 1)
        {
            if (type == Type.FOUR_OF_A_KIND)
            {
                type = Type.FIVE_OF_A_KIND;
            }
            else if (type == Type.THREE_OF_A_KIND)
            {
                type = Type.FOUR_OF_A_KIND;
            }
            else if (type == Type.ONE_PAIR)
            {
                type = Type.THREE_OF_A_KIND;
            }
            else if (type == Type.TWO_PAIR)
            {
                type = Type.FULL_HOUSE;
            }
            else
            {
                type = Type.ONE_PAIR;
            }
        }
    }

    public int CompareTo(Hand? other)
    {
        if (type != other?.type)
        {
            return (type - other?.type) ?? 1;
        }
        for (int i = 0; i < 5; i++)
        {
            int thisVal = GetValue(cardOrder[i]);
            int otherVal = GetValue(other.cardOrder[i]);
            if (thisVal != otherVal)
            {
                return thisVal - otherVal;
            }
        }
        return 0;
    }

    private static int GetValue(char c)
    {
        if (char.IsNumber(c)) return c - '0';
        return c switch
        {
            'A' => 14,
            'K' => 13,
            'Q' => 12,
            'J' => 11,
            'T' => 10,
            _ => 0,
        };
    }
}
