#pragma once

#include "vflib/argraph.h"

class Label
{
  public:
	int label;
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