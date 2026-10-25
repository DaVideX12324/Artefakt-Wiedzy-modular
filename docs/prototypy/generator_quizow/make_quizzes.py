"""Generator zestawów pytań (JSON) w formacie resources/quizzes: 5 typów, trudność 1-5, kategorie, deterministyczne tasowanie."""
import json, random, sys, os, re

OUT = sys.argv[1]


class Quiz:
    def __init__(self, qid, name, desc):
        self.qid, self.name, self.desc = qid, name, desc
        self.qs = []
        self.n = {"mc": 0, "tf": 0, "ft": 0, "ftext": 0, "match": 0}

    def _id(self, kind):
        self.n[kind] += 1
        return "%s_%03d" % ({"mc": "mc", "tf": "tf", "ft": "ft", "ftext": "ftext", "match": "match"}[kind], self.n[kind])

    def _rng(self, qid):
        return random.Random("%s/%s" % (self.qid, qid))

    def mc(self, diff, cat, question, correct, wrong):
        qid = self._id("mc")
        answers = [correct] + list(wrong)
        assert len(answers) == 4 and len(set(answers)) == 4, (qid, answers)
        self._rng(qid).shuffle(answers)
        self.qs.append({"id": qid, "type": "multiple_choice", "difficulty": diff, "category": cat, "question": question,
                        "answers": answers, "correct_index": answers.index(correct)})

    def tf(self, diff, cat, statement, value):
        qid = self._id("tf")
        self.qs.append({"id": qid, "type": "true_false", "difficulty": diff, "category": cat, "statement": statement,
                        "correct_answer": value})

    def ft(self, diff, cat, text, gaps, distractors):
        qid = self._id("ft")
        assert text.count("___") == len(gaps), (qid, text)
        tiles = list(gaps) + list(distractors)
        assert len(set(tiles)) == len(tiles), (qid, tiles)
        self._rng(qid).shuffle(tiles)
        self.qs.append({"id": qid, "type": "fill_tiles", "difficulty": diff, "category": cat, "text_with_gaps": text,
                        "gaps": [{"index": i, "correct": g} for i, g in enumerate(gaps)], "tiles": tiles})

    def ftext(self, diff, cat, prompt, answer, alts=()):
        qid = self._id("ftext")
        pattern = " ".join((w[0] + "_" * (len(w) - 2) + w[-1]) if len(w) >= 3 else w for w in answer.split(" "))
        q = {"id": qid, "type": "fill_text", "difficulty": diff, "category": cat, "prompt": prompt, "answer": answer,
             "prefilled_pattern": pattern, "case_sensitive": False}
        if alts:
            q["accepted_alternatives"] = list(alts)
        self.qs.append(q)

    def match(self, diff, cat, pairs, question=None):
        qid = self._id("match")
        left = [p[0] for p in pairs]
        right = [p[1] for p in pairs]
        assert len(set(left)) == len(left) and len(set(right)) == len(right), qid
        order = list(range(len(pairs)))
        self._rng(qid).shuffle(order)
        shuffled = [right[i] for i in order]
        q = {"id": qid, "type": "matching", "difficulty": diff, "category": cat, "left_items": left, "right_items": shuffled,
             "pairs": [{"left_index": i, "right_index": shuffled.index(right[i])} for i in range(len(pairs))]}
        self.qs.append(q)

    def save(self):
        d = {"name": self.name, "description": self.desc, "questions": self.qs}
        text = json.dumps(d, ensure_ascii=False, indent=2).replace("\n", "\r\n")
        with open(os.path.join(OUT, self.qid + ".json"), "w", encoding="utf-8", newline="") as f:
            f.write(text)
        c = {}
        for q in self.qs:
            c[q["difficulty"]] = c.get(q["difficulty"], 0) + 1
        print(self.qid, len(self.qs), "pytań; trudność:", dict(sorted(c.items())))


for _f in ("quizzes_content1.py", "quizzes_content2.py"):
    exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), _f), encoding="utf-8").read())
