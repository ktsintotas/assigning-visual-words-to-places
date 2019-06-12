# Assigning Visual Words to Places for Loop Closure Detection

This open source MATLAB algorith presents an efficient image-to-sequence appearance-based loop closure detection method. Using a voting scheme over the on-line generated Visual Words (VWs) and coupling the method with a probability function, the pipeline is able to accurately detect revisited places. Dynamic sequence segmentation is performed on the incoming image stream formulating “places” on the robot’s navigated path. Subsequently, the accumulated local feature descriptors are processed by a Growing Neural Gas clustering mechanism for the corresponding VWs generation. When new query images enter to the pipeline, the extracted descriptors assign votes to the database sequences including their nearest neighboring VWs. The system uses a binomial probability density function to locate the proper candidate place and a nearest descriptor neighbor technique to identify image-to-image associations within the selected loop closing sequence. Temporal and geometrical consistency checks are performed between the query and candidate image, providing a higher level of discrimination.

Note that the given framework is a research code. The authors are not responsible for any errors it may contain. **Use it at your own risk!**

## Conditions of use
Assigning-visual-words-to-places is distributed under the terms of the [MIT License](https://github.com/ktsintotas/Bag-of-Tracked-Words/blob/master/LICENSE).

## Related publication
The details of the algorithm are explained in the [following publication](https://ieeexplore.ieee.org/abstract/document/8461146):

**Assigning Visual Words to Places for Loop Closure Detection<br/>**
Konstantinos A. Tsintotas, Loukas Bampis, and Antonios Gasteratos<br/>
IEEE International Conference on Robotics and Automation (ICRA), Pgs. 1 - 7 (May 2018)

If you use this code, please cite:

```
@inproceedings{tsintotas2018places,
  title={Assigning Visual Words to Places for Loop Closure Detection},  
  author={K. A. Tsintotas and L. Bampis and A. Gasteratos},   
  booktitle={IEEE International Conference on Robotics and Automation (ICRA)},
  pages={1 - 7},
  year={2019},   
  month={April}, 
  doi={10.1109/ICRA.2018.8461146} 
}
```
## Contact
If you have problems or questions using this code, please contact the author (ktsintot@pme.duth.gr). Ground truth requests and contributions are totally welcome.
