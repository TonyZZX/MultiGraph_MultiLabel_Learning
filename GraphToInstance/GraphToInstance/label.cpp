#include "label.h"

Label::Label(int label)
{
	this->label = label;
}

void LabelDestroyer::destroy(void *l)
{
	delete static_cast<Label *>(l);
}

bool LabelComparator::compatible(void *m, void *n)
{
	auto *l_m = (Label *)m;
	auto *l_n = (Label *)n;
	return l_m->label == l_n->label;
}

std::istream &operator>>(std::istream &in, Label &l)
{
	in >> l.label;
	return in;
}

std::ostream &operator<<(std::ostream &out, Label &l)
{
	out << l.label;
	return out;
}
