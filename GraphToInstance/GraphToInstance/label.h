#pragma once

#include <iostream>

#include "vflib/argraph.h"

class Label
{
public:
	int label;
	Label() = default;
	Label(int label);
};

class LabelDestroyer : public AttrDestroyer
{
public:
	virtual void destroy(void *l);
};

class LabelComparator : public AttrComparator
{
public:
	virtual bool compatible(void *m, void *n);
};

std::istream &operator>>(std::istream &in, Label &l);

std::ostream &operator<<(std::ostream &out, Label &l);