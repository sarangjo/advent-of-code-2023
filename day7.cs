class Day7
{
    static void Main()
    {
        var lines = File.ReadLines("day7.txt");

        SortedSet<Hand> hands = [];
        foreach (var line in lines)
        {
            string[] parts = line.Split(' ');
            hands.Add(new(parts[0], int.Parse(parts[1])));
        }

        int sum = 0;
        int rank = 1;
        foreach (var h in hands)
        {
            sum += rank * h.bid;
            rank++;
        }

        Console.WriteLine(sum);
    }
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
    public IOrderedEnumerable<KeyValuePair<char, int>> sortedCards;
    public Type type = Type.HIGH_CARD;
    public int bid;

    public Hand(string def, int bid)
    {
        cardOrder = def;
        this.bid = bid;

        var cards = new Dictionary<char, int>();

        foreach (var c in def)
        {
            cards[c] = cards.TryGetValue(c, out int value) ? value + 1 : 1;
        }

        sortedCards = (from entry in cards orderby entry.Value descending select entry);

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

    public static int GetValue(char c)
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
