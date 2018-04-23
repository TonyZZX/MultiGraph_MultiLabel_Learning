import matplotlib.pyplot as plt
import numpy as np

from skimage.data import astronaut
from skimage.segmentation import felzenszwalb, slic, quickshift
from skimage.segmentation import mark_boundaries
from skimage.util import img_as_float

img = img_as_float(astronaut()[::2, ::2])

segments_slic = slic(img, sigma=1, n_segments=400)
segments_quick = quickshift(img, sigma=1, max_dist=8)

print('SLIC number of segments: {}'.format(len(np.unique(segments_slic))))
print('Quickshift number of segments: {}'.format(len(np.unique(segments_quick))))

_, ax = plt.subplots(nrows=1, ncols=2, figsize=(
    10, 10), sharex=True, sharey=True)

ax[0].imshow(mark_boundaries(img, segments_slic))
ax[0].set_title('SLIC')
ax[1].imshow(mark_boundaries(img, segments_quick))
ax[1].set_title('Quickshift')

for a in ax.ravel():
    a.set_axis_off()

plt.tight_layout()
plt.show()
