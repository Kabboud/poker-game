defmodule Poker do
	def deal([a, b, c, d | river]) do
		p1hands = hands([a, c | river], 5) -- [river]
		p2hands = hands([b, d | river], 5) -- [river]
		p1result = bestHand(hd(p1hands), p1hands, 0)
		p1score = hd(tl(p1result))
		p1hand = hd(p1result)
		p2result = bestHand(hd(p2hands), p2hands, 0)
		p2score = hd(tl(p2result))
		p2hand = hd(p2result)
		
		cond do
			p1score > p2score -> categorizeCards(p1hand)
			p2score > p1score -> categorizeCards(p2hand)
			p1score == p2score -> categorizeCards(tieBreak(p1hand, p2hand, p1score))
			true -> "Do Nothing"
		end
	end
	
	def bestHand(best, [], score), do: [best, score]
	def bestHand(best, [hand | rest], score) do
		cardCount = cardCount(hand)
		tempScore = cond do
			isStraight(hand) && isFlush(hand) -> 9
			isFlush(hand) -> 6
			isStraight(hand) -> 5
			Enum.count(cardCount, fn(n) -> n == 1 end) == 5 -> 1
			Enum.count(cardCount, fn(n) -> n == 1 end) == 3 -> 2
			Enum.count(cardCount, fn(n) -> n == 2 end) == 2 -> 3
			(Enum.count(cardCount, fn(n) -> n == 3 end) == 1) && (Enum.count(cardCount, fn(n) -> n == 1 end) == 2) -> 4
			(Enum.count(cardCount, fn(n) -> n == 3 end) == 1) && (Enum.count(cardCount, fn(n) -> n == 2 end) == 1) -> 7
			(Enum.count(cardCount, fn(n) -> n == 4 end) == 1) && (Enum.count(cardCount, fn(n) -> n == 1 end) == 1) -> 8
			true -> "Do Nothing"
		end
		cond do
			tempScore == score -> bestHand(tieBreak(best, hand, score), rest, score)
			tempScore > score -> bestHand(hand, rest, tempScore)
			tempScore < score -> bestHand(best, rest, score)
			true -> "Do Nothing"
		end
	end

	def hands(_, 0), do: [[]]
	def hands([], _), do: []
	def hands([h | t], size) do
		Enum.map(hands(t, size - 1), &[h | &1]) ++ hands(t, size)
	end

	def cardCount(list) do
		countArr = for n <- list, do: rem((rem(n-1,13)+13),13)+1
		c1 = Enum.count(countArr, fn(n) -> n == 1 end) 
		c2 = Enum.count(countArr, fn(n) -> n == 2 end) 
		c3 = Enum.count(countArr, fn(n) -> n == 3 end) 
		c4 = Enum.count(countArr, fn(n) -> n == 4 end) 
		c5 = Enum.count(countArr, fn(n) -> n == 5 end) 
		c6 = Enum.count(countArr, fn(n) -> n == 6 end) 
		c7 = Enum.count(countArr, fn(n) -> n == 7 end) 
		c8 = Enum.count(countArr, fn(n) -> n == 8 end) 
		c9 = Enum.count(countArr, fn(n) -> n == 9 end) 
		c10 = Enum.count(countArr, fn(n) -> n == 10 end) 
		c11 = Enum.count(countArr, fn(n) -> n == 11 end) 
		c12 = Enum.count(countArr, fn(n) -> n == 12 end) 
		c13 = Enum.count(countArr, fn(n) -> n == 13 end) 
		[c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13]
	end
	
	def isFlush(list), do: isFlush(list, [])
	def isFlush([], suits), do: Enum.count(suits, fn(n) -> n == hd(suits) end) == 5
	def isFlush([head | tail], suits) do
		cond do
			head <= 13 -> isFlush(tail, suits ++ ['C'])
			(head > 13) && (head <= 26) -> isFlush(tail, suits ++ ['D'])
			(head > 26) && (head <= 39) -> isFlush(tail, suits ++ ['H'])
			(head > 39) && (head <= 52) -> isFlush(tail, suits ++ ['S'])
			true -> "Do Nothing"
		end
	end
	
	def isStraight(list) do	
		low = [1, 2, 3, 4, 5]
		high = [1, 10, 11, 12, 13]
		
		unsorted = for n <- list, do: rem((rem(n-1,13)+13),13)+1
		sorted = Enum.sort(unsorted)
		[a, b, c, d, e] = sorted
		
		cond do
			(low == sorted) || (high == sorted) -> true
			a != (b-1) -> false
			b != (c-1) -> false
			c != (d-1) -> false
			d != (e-1) -> false
			true -> true
		end
	end
	
	def tieBreak(hand, hand, _), do: hand
	def tieBreak(hand1, hand2, score) do
		tempHand1 = for n <- hand1, do: rem((rem(n-1,13)+13),13)+1
		tempHand2 = for n <- hand2, do: rem((rem(n-1,13)+13),13)+1
		dupes1 = Enum.count(tempHand1, fn(n) -> n == 1 end)
		dupes2 = Enum.count(tempHand2, fn(n) -> n == 1 end)
		tempHand1 = (tempHand1 -- List.duplicate(1, dupes1)) ++ List.duplicate(14, dupes1)
		tempHand2 = (tempHand2 -- List.duplicate(1, dupes2)) ++ List.duplicate(14, dupes2)
		
		cond do
			(score == 1 || score == 6) && (highCard(tempHand1, tempHand2) == tempHand1) -> hand1
			((score == 1) || (score == 6)) && (highCard(tempHand1, tempHand2) == tempHand2) -> hand2
			score == 2 -> 
				temp1 = tempHand1 -- Enum.uniq(tempHand1)
				temp2 = tempHand2 -- Enum.uniq(tempHand2)
				cond do
					hd(temp1) > hd(temp2) -> hand1
					hd(temp2) > hd(temp1) -> hand2
					hd(temp1) == hd(temp2) -> 
						tempHand1 = (tempHand1 -- [hd(temp1)]) -- [hd(temp1)]
						tempHand2 = (tempHand2 -- [hd(temp2)]) -- [hd(temp2)]
						winner = highCard(tempHand1, tempHand2)
						cond do
							winner == tempHand1 -> hand1
							winner == tempHand2 -> hand2
							true -> "Do Nothing"
						end
					true -> "Do Nothing"
				end
			score == 3 -> 
				temp1 = Enum.sort(tempHand1 -- Enum.uniq(tempHand1), :desc)
				temp2 = Enum.sort(tempHand2 -- Enum.uniq(tempHand2), :desc)
				cond do
					hd(temp1) > hd(temp2) -> hand1
					hd(temp2) > hd(temp1) -> hand2
					hd(temp1) == hd(temp2) -> 
						tempHand1 = (tempHand1 -- [hd(temp1)]) -- [hd(temp1)]
						tempHand2 = (tempHand2 -- [hd(temp2)]) -- [hd(temp2)]
						temp1 = (temp1 -- [hd(temp1)]) -- [hd(temp1)] 
						temp2 = (temp2 -- [hd(temp2)]) -- [hd(temp2)]
						cond do
							hd(temp1) > hd(temp2) -> hand1
							hd(temp2) > hd(temp1) -> hand2
							hd(temp1) == hd(temp2) -> 
								tempHand1 = (tempHand1 -- [hd(temp1)]) -- [hd(temp1)]
								tempHand2 = (tempHand2 -- [hd(temp2)]) -- [hd(temp2)]
								winner = highCard(tempHand1, tempHand2)
								cond do
									winner == tempHand1 -> hand1
									winner == tempHand2 -> hand2
									true -> "Do Nothing"
								end
							true -> "Do Nothing"
						end
					true -> "Do Nothing"
				end
			score == 4 ->
				temp1 = tempHand1 -- Enum.uniq(tempHand1)
				temp2 = tempHand2 -- Enum.uniq(tempHand2)
				cond do
					hd(temp1) > hd(temp2) -> hand1
					hd(temp2) > hd(temp1) -> hand2
					hd(temp1) == hd(temp2) -> 
						tempHand1 = ((tempHand1 -- [hd(temp1)]) -- [hd(temp1)]) -- [hd(temp1)]
						tempHand2 = ((tempHand2 -- [hd(temp2)]) -- [hd(temp2)]) -- [hd(temp2)]
						winner = highCard(tempHand1, tempHand2)
						cond do
							winner == tempHand1 -> hand1
							winner == tempHand2 -> hand2
							true -> "Do Nothing"
						end
					true -> "Do Nothing"
				end
			(score == 5) || (score == 9) ->
				tempHand1 = cond do
					Enum.member?(tempHand1, 2) && Enum.member?(tempHand1, 14) -> fixAces(tempHand1)
					true -> tempHand1
				end
				tempHand2 = cond do
					Enum.member?(tempHand2, 2) && Enum.member?(tempHand2, 14) -> fixAces(tempHand2)
					true -> tempHand2
				end
				winner = highCard(tempHand1, tempHand2)
				cond do
					winner == tempHand1 -> hand1
					winner == tempHand2 -> hand2
					true -> "Do Nothing"
				end
			score == 7 -> 
				temp1 = (tempHand1 -- Enum.uniq(tempHand1)) -- Enum.uniq(tempHand1)
				temp2 = (tempHand2 -- Enum.uniq(tempHand2)) -- Enum.uniq(tempHand2)
				cond do
					hd(temp1) > hd(temp2) -> hand1
					hd(temp2) > hd(temp1) -> hand2
					hd(temp1) == hd(temp2) -> 
						tempHand1 = ((tempHand1 -- [hd(temp1)]) -- [hd(temp1)]) -- [hd(temp1)]
						tempHand2 = ((tempHand2 -- [hd(temp2)]) -- [hd(temp2)]) -- [hd(temp2)]
						winner = highCard(tempHand1, tempHand2)
						cond do
							winner == tempHand1 -> hand1
							winner == tempHand2 -> hand2
							true -> "Do Nothing"
						end
					true -> "Do Nothing"
				end
			score == 8 ->
				temp1 = tempHand1 -- Enum.uniq(tempHand1)
				temp2 = tempHand2 -- Enum.uniq(tempHand2)
				cond do
					hd(temp1) > hd(temp2) -> hand1
					hd(temp2) > hd(temp1) -> hand2
					hd(temp1) == hd(temp2) -> 
						tempHand1 = (((tempHand1 -- [hd(temp1)]) -- [hd(temp1)]) -- [hd(temp1)]) -- [hd(temp1)]
						tempHand2 = (((tempHand2 -- [hd(temp2)]) -- [hd(temp2)]) -- [hd(temp2)]) -- [hd(temp2)]
						winner = highCard(tempHand1, tempHand2)
						cond do
							winner == tempHand1 -> hand1
							winner == tempHand2 -> hand2
							true -> "Do Nothing"
						end
					true -> "Do Nothing"
				end
			true -> hand1
		end
	end
	
	def fixAces(list), do: fixAces(list, [])
	def fixAces([], list), do: list
	def fixAces([head | tail], list) do
		tList = list
		tList = cond do
			head == 14 -> tList ++ [1]
			true -> tList ++ [head]
		end
		fixAces(tail, tList)
	end
	
	def highCard(hand1, hand2), do: highCard(hand1, hand2, hand1, hand2)
	def highCard(hand1, _, [], []), do: hand1
	def highCard(hand1, hand2, tHand1, tHand2) do
		tempHand1 = tHand1
		tempHand2 = tHand2
		max1 = Enum.max(tempHand1)
		max2 = Enum.max(tempHand2)
		tempHand1 = tempHand1 -- [max1]
		tempHand2 = tempHand2 -- [max2]
		cond do
			max1 > max2 -> hand1
			max1 < max2 -> hand2
			max1 == max2 -> highCard(hand1, hand2, tempHand1, tempHand2)
			true -> "Do Nothing"
		end
	end	
	
	def categorizeCards(list), do: categorizeCards(list, [])
	def categorizeCards([], result), do: result
	def categorizeCards([head | tail], result) do
		strCard = Integer.to_string(rem((rem(head-1,13)+13),13)+1)
		tResult = cond do
			head <= 13 -> result ++ [strCard <> "C"]
			(head > 13) && (head <= 26) -> result ++ [strCard <> "D"]
			(head > 26) && (head <= 39) -> result ++ [strCard <> "H"]
			(head > 39) && (head <= 52) -> result ++ [strCard <> "S"]
			true -> "Do Nothing"
		end
		categorizeCards(tail, tResult)
	end
end