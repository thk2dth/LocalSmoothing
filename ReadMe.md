# Benchmark of analytical corner smoothing methods.

We try to compare our method with two existing analytical local smoothing methods: [Bi2015IJMTM](http://www.sciencedirect.com/science/article/pii/S0890695515300080) and [Yang2017IJMTM](http://www.sciencedirect.com/science/article/pii/S0890695517301153). The algorithms are written in Matlab for implementation simplicity, and the implementations are optimized as possible as we can.


## Comparison Index.
Two indexes are used here: *consuming time* and *error control ability*. The consuming time only counts the computation time for local smoothing and parameter synchronization. After smoothing and synchronization, the actual smoothing errors are numerically calculated off-line. Since tolerance control of the position smoothing error is trivial, we only calculate the orientation smoothing error. Mathematically, the smoothing error is the Hausdorff's distance between the inserted curve and the corner being replaced. However, the Hausdorff's distance is difficult to calculated. We use two errors to evaluate the smoothing error here. (a) Minimum error: The minimum angle between the point on the inserted parametric curve and the corner point. (b) Error at the middle point of the inserted curve. The first error can be regarded as an upper approximation of the Hausdorff's distance between the inserted curve and the corner being replaced. The second error is consistent with the assumption in orientation smoothing: The orientation smoothing error is assumed to be attained at the middle point of the parametric curve. In our paper, we have pointed out that the two distances are generally different. Specifically, the first error is smaller than the second.

The proposed method is supposed to be **higher in computation efficiency** and to show **tighter tolerance in error control** due to the following two reasons:
- Since the proposed method involves no kinematic transformation, it involves much less computation burden.
- Since the proposed method directly controls the smoothing errors in the workpiece coordinate system (WCS), it can tightly control the orientation smoothing error and will be more robust.

## Algorithm description.
In Bi's method, the tool position and the tool orientation were both smoothed in the machine coordinate system (MCS). In Yang's method, the tool position is smoothed in the WCS, while the tool orientation in the MCS. The proposed method smooths the tool position and tool orientation both in the WCS. Therefore, it involves no kinematic transformation and controls the smoothing error directly. Our method is similar to Bi's method in the sense that the smooth path is G<sup>2</sup> continuous after smoothing and C<sup>1</sup> continuous after synchronization. Yang's method can achieve C<sup>3</sup> continuity after synchronization. However, since these methods are all analytical, the continuity order will have little influence on the computation complexity.
Note that in Bi's method, Equation (13) cannot be derived from equation (10), and || &Delta;Q<sub>MT</sub>|| cannot be determined by equation (5) even if || &Delta;Q<sub>MR</sub>|| is given. Nevertheless, as assumed in Yang's method, the smoothing error in WCS can be mapped to MCS if the errors are supposed to be small. However, if the smoothing errors are large (e.g., in CAM applications), Bi's and Yang's methods may fail.

## Implementation details.
The benchmark is designed as follows.
1. A specified number of cutter data is randomly sampled in the MCS within the strides of the machine tool. The cutter data in the WCS is then obtained via forward kinematic transformation (FKT). The data is sampled in MCS to avoid multiple selection during inverse kinematic transformation (IKT).
2. The proposed method is applied to the WCS data, and Yang's method is applied to MCS data.
3. After smoothing and synchronization, two smoothing errors are numerically calculated off-line. 
4. The Bezier curves in Bi's method are expressed by B-spines with knot vector [0,0,0,0,1,1,1,1].
5. 5001 points are sampled on each inserted B-spline and used to calculate the angle with the corner point.
6. The NURBS toolbox developed by D.M. Spink is used. It is available at [Matlab Central](http://cn.mathworks.com/matlabcentral/fileexchange/26390-nurbs-toolbox-by-d-m-spink).


## Results.
First, the two methods (the proposed and Yang's) are compared by consuming time. Each algorithm runs 100 times. At each run, a specified number of cutter data is generated and smoothed. The consuming times are recorded, and the average value is adopted as the consuming time for the algorithms. Our method is on average 34.0% faster than Yang's method.
Second, the two methods are compared with error control ability. A sufficiently large number (e.g., 2000) of cutter data is randomly generated and smoothed by the two methods. The two aforementioned errors are calculated. As can be seen from the results, the proposed method has tight tolerance in control the orientation smoothing error, while Yang's method has a slack control. In addition, our method can make full use of the error tolerance, as can be observed from the ratio between the minimum error and the middle point error. The local smoothing methods usually uses the convex property of the inserted parametric curves to control the smoothing error. However, the convex property of the inserted curve is lost after the non-linear kinematic transformation. As a result, the smoothing method cannot tightly control the smoothing errors if kinematic transformation is involved.

**Remark I.** During comparison, it is found that Bi's method is not robust enough due to the coupling of the position and orientation errors. After determining || &Delta;Q<sub>MR</sub>||, equation (5) may suggest a negative value for || &Delta;Q<sub>MT</sub>||, which is impractical. The reason is that ||J'<sub>TR</sub> * J'<sub>TR</sub>|| can be quite large. Therefore, we did not compare our algorithm with Bi's method. Nevertheless, Bi's method is also provided in the given files.

**Remark II.** We have stored the simulation results in two files (resultsConsumingTime.mat and resultsWithDataNumer2000.mat) in case the simulation process is too slow on some computers. The first file contains the information of the consuming time with respect to the cutter data number. The second file contains the information of the smoothing errors when smoothing 2000 cutter data. Since the cutter data is sampled randomly, the results can be slightly different.

If you find these files useful, please cite our paper:
Jie Huang, Xu Du, Li-Min Zhu, Real-time local smoothing for five-axis linear toolpath considering smoothing error constraints, In International Journal of Machine Tools and Manufacture, Volume 124, 2018, Pages 67-79, ISSN 0890-6955, https://doi.org/10.1016/j.ijmachtools.2017.10.001.

If you have any problem, feel free to contact us by the following information:
Author, Jie Huang; Email, thk2dth@sjtu.edu.cn;
Institution, State Key Laboratory of Mechanical System and Vibration, School of Mechanical Engineering, Shanghai Jiao Tong University, Shanghai 200240, P.R. China.